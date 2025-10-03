import AppKit
import KeyboardShortcuts
import SwiftUI
import OSLog
import MarkdownUI

private let logger = Logger(subsystem: "com.familiar.app", category: "FamiliarWindow")

private final class FamiliarPanel: NSPanel {
    override func cancelOperation(_ sender: Any?) {
        orderOut(sender)
    }
}
final class FamiliarWindowController: NSObject, ObservableObject {
    static let shared = FamiliarWindowController()

    private let hostingController: NSHostingController<FamiliarView>
    private lazy var panel: NSPanel = {
        let panel = FamiliarPanel(contentViewController: hostingController)
        panel.titleVisibility = .hidden
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.styleMask = [.nonactivatingPanel, .titled, .fullSizeContentView, .closable, .resizable]
        panel.level = .statusBar
        panel.collectionBehavior = [.fullScreenAuxiliary, .canJoinAllSpaces]
        panel.isReleasedWhenClosed = false
        panel.setFrameAutosaveName("FamiliarMainWindow")
        return panel
    }()

    private override init() {
        logger.info("🎮 Initializing controller")
        // Create hosting controller eagerly (triggers FamiliarView/ViewModel creation)
        self.hostingController = NSHostingController(rootView: FamiliarView())
        logger.info("🎮 Hosting controller created")

        super.init()
        KeyboardShortcuts.onKeyUp(for: .summon) { [weak self] in
            self?.toggle()
        }
    }

    func toggle() {
        let window = panel
        if window.isVisible {
            logger.info("🪟 Closing window")
            window.orderOut(nil)
        } else {
            logger.info("🪟 Opening window")
            window.center()
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

struct FamiliarView: View {
    @StateObject private var viewModel = FamiliarViewModel()
    @FocusState private var isPromptFocused: Bool
    @State private var isSettingsPresented = false
    @StateObject private var settingsAppState = AppState(startMonitoring: false)

    var body: some View {
        VStack(spacing: FamiliarSpacing.sm) {
            // Top content region: zero state OR transcript content
            Group {
                if viewModel.transcript.isEmpty && viewModel.prompt.isEmpty && !viewModel.isStreaming {
                    ZeroStateView(
                        onSuggestionTap: { suggestion in
                            viewModel.handleSuggestionTap(suggestion)
                        },
                        fetchSuggestions: {
                            await viewModel.fetchZeroStateSuggestions()
                        }
                    )
                    .transition(.opacity.animation(.familiar))
                } else {
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: true) {
                            LazyVStack(alignment: .leading, spacing: FamiliarSpacing.sm) {
                                if !viewModel.transcript.isEmpty {
                                    Markdown(viewModel.transcript)
                                        .markdownTheme(.familiar)
                                        .textSelection(.enabled)
                                        .lineSpacing(2) // Ensure minimum spacing to prevent concatenation
                                        .transaction { $0.animation = nil } // Prevent jitter while streaming
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }

                                if let summary = viewModel.toolSummary {
                                    ToolSummaryView(summary: summary)
                                }

                                if let error = viewModel.errorMessage {
                                    Label(error, systemImage: "exclamationmark.circle")
                                        .foregroundStyle(Color.familiarError)
                                }

                                // Bottom anchor for auto-scroll during streaming
                                Color.clear.frame(height: 1).id("BOTTOM")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 1) // Prevent content from touching scroll edges
                        }
                        .onChange(of: viewModel.isStreaming) { isStreaming in
                            // Scroll to bottom when streaming starts or stops
                            if isStreaming {
                                proxy.scrollTo("BOTTOM", anchor: .bottom)
                            } else {
                                // Final scroll when streaming completes
                                withAnimation(.easeOut(duration: 0.2)) {
                                    proxy.scrollTo("BOTTOM", anchor: .bottom)
                                }
                            }
                        }
                        .task(id: viewModel.transcript.count) {
                            // Debounced scroll during streaming (only when transcript length changes)
                            guard viewModel.isStreaming else { return }
                            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms debounce
                            guard !Task.isCancelled else { return }
                            proxy.scrollTo("BOTTOM", anchor: .bottom)
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .overlay(
                        RoundedRectangle(cornerRadius: FamiliarRadius.card)
                            .stroke(Color(nsColor: .separatorColor).opacity(0.25), lineWidth: 1)
                    )
                }
            }

            if let totals = viewModel.usageTotalsDisplay {
                UsageSummaryView(totals: totals, last: viewModel.lastUsageDisplay)
            }

            if viewModel.isStreaming {
                HStack(spacing: FamiliarSpacing.xs) {
                    BreathingDotView()
                    Text(viewModel.loadingMessage ?? "Working on it…")
                        .font(.familiarCaption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .animation(.familiar, value: viewModel.isStreaming)
            }

            Spacer(minLength: 0)

            Divider()

            // Prompt composer region (always visible)
            VStack(alignment: .leading, spacing: FamiliarSpacing.xs / 2) {
                HStack(alignment: .center, spacing: FamiliarSpacing.xs) {
                    PromptTextEditor(
                        text: $viewModel.prompt,
                        preview: viewModel.promptPreview,
                        onSubmit: viewModel.submit,
                        onPaste: viewModel.handlePaste,
                        onBeginEditing: viewModel.beginEditingPrompt
                    )
                    .focused($isPromptFocused)

                    if viewModel.isStreaming {
                        Button {
                            viewModel.cancelStreaming()
                        } label: {
                            Label("Stop", systemImage: "stop.circle.fill")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .tint(.familiarWarning)
                        .help("Stop current request")
                    } else {
                        Button {
                            viewModel.submit()
                        } label: {
                            Label("Send", systemImage: "paperplane.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .help("Send prompt (Enter)")
                    }
                }

                HStack(spacing: 0) {
                    Text("New line: Shift+Enter    Send: Enter")
                        .font(.familiarCaption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        // Gear button overlay (top-right)
        .overlay(alignment: .topTrailing) {
            Button {
                isSettingsPresented = true
            } label: {
                Image(systemName: "gearshape")
                    .imageScale(.medium)
                    .foregroundStyle(.secondary)
                    .padding(FamiliarSpacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: FamiliarRadius.control)
                            .fill(Color.familiarSurfaceElevated.opacity(0.6))
                    )
            }
            .buttonStyle(.borderless)
            .help("Open Settings")
            .padding(.trailing, FamiliarSpacing.sm)
            .padding(.top, FamiliarSpacing.sm)
        }
        .padding(EdgeInsets(
            top: FamiliarSpacing.md,
            leading: FamiliarSpacing.md,
            bottom: FamiliarSpacing.sm,
            trailing: FamiliarSpacing.md
        ))
        .frame(
            minWidth: 600,
            idealWidth: 720,
            maxWidth: 900,
            minHeight: 520,
            idealHeight: 620,
            maxHeight: .infinity,
            alignment: .top
        )
        .sheet(item: $viewModel.permissionRequest) { request in
            ApprovalSheet(request: request, isProcessing: viewModel.isProcessingPermission) { decision in
                viewModel.respond(
                    to: request,
                    decision: decision.decision,
                    remember: decision.remember
                )
            }
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView(appState: settingsAppState, autoDismissOnSave: true)
                .environmentObject(settingsAppState)
        }
        .onAppear {
            isPromptFocused = true
            viewModel.evaluateInactivityReset()
        }
        .onExitCommand {
            FamiliarWindowController.shared.toggle()
        }
        // Confirm external link opens from Markdown content
        .environment(\.openURL,
            OpenURLAction { url in
                guard let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) else {
                    return .discarded
                }
                let alert = NSAlert()
                alert.messageText = "Open link?"
                let host = url.host ?? url.absoluteString
                alert.informativeText = "Open \(host) in your browser?"
                alert.addButton(withTitle: "Yes, open")
                alert.addButton(withTitle: "Not right now")
                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    NSWorkspace.shared.open(url)
                    return .handled
                } else {
                    return .discarded
                }
            }
        )
    }
}
