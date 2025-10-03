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
        panel.titlebarAppearsTransparent = true
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.styleMask = [.nonactivatingPanel, .titled, .fullSizeContentView, .closable, .resizable]
        panel.level = .statusBar
        panel.collectionBehavior = [.fullScreenAuxiliary, .canJoinAllSpaces]
        panel.isReleasedWhenClosed = false
        panel.setFrameAutosaveName("FamiliarMainWindow")
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var userAtBottom: Bool = true
    @State private var viewportHeight: CGFloat = 0
    @State private var bottomMaxY: CGFloat = 0

    private let bottomThreshold: CGFloat = 20

    var body: some View {
        VStack(spacing: FamiliarSpacing.sm) {
            // Top content region: zero state OR transcript content
            if viewModel.entries.isEmpty && viewModel.prompt.isEmpty && !viewModel.isStreaming {
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
                            LazyVStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
                                // Transcript entries column (max width 680, left aligned)
                                LazyVStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
                                    // Skeleton while planning/tooling before first reply chunk
                                    if viewModel.isStreaming,
                                       let phase = viewModel.currentPhase,
                                       phaseIsPreReply(phase),
                                       (viewModel.entries.last?.role == .assistant),
                                       ((viewModel.entries.last?.text.isEmpty) == true) {
                                        ShimmerLinesView()
                                    }
                                    ForEach(viewModel.entries) { entry in
                                        TranscriptEntryView(entry: entry)
                                            .transition(.opacity)
                                    }

                                    if let summary = viewModel.toolSummary {
                                        ToolSummaryView(summary: summary)
                                    }

                                    if let error = viewModel.errorMessage {
                                        StatusBannerView(summary: "Hmm, something went wrong", details: error)
                                    }

                                    // Bottom anchor for auto-scroll during streaming
                                    Color.clear
                                        .frame(height: 1)
                                        .id("BOTTOM")
                                        .background(
                                            GeometryReader { gp in
                                                Color.clear
                                                    .preference(
                                                        key: BottomMaxYPreferenceKey.self,
                                                        value: gp.frame(in: .named("TranscriptScroll")).maxY
                                                    )
                                            }
                                        )
                                }
                                .frame(maxWidth: 680, alignment: .leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 1)
                        }
                        .coordinateSpace(name: "TranscriptScroll")
                        .background(
                            GeometryReader { gp in
                                Color.clear
                                    .preference(key: ViewportHeightPreferenceKey.self, value: gp.size.height)
                            }
                        )
                        .onPreferenceChange(ViewportHeightPreferenceKey.self) { h in
                            viewportHeight = h
                            updateUserAtBottom()
                        }
                        .onPreferenceChange(BottomMaxYPreferenceKey.self) { y in
                            bottomMaxY = y
                            updateUserAtBottom()
                        }
                        .onChange(of: viewModel.isStreaming) { isStreaming in
                            if isStreaming {
                                if userAtBottom { proxy.scrollTo("BOTTOM", anchor: .bottom) }
                            } else {
                                if userAtBottom {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        proxy.scrollTo("BOTTOM", anchor: .bottom)
                                    }
                                }
                            }
                        }
                        .task(id: viewModel.entries.last?.text.count ?? 0) {
                            guard viewModel.isStreaming else { return }
                            try? await Task.sleep(nanoseconds: 100_000_000)
                            guard !Task.isCancelled else { return }
                            if userAtBottom { proxy.scrollTo("BOTTOM", anchor: .bottom) }
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .overlay(
                        RoundedRectangle(cornerRadius: FamiliarRadius.card)
                            .stroke(Color(nsColor: .separatorColor).opacity(0.25), lineWidth: 1)
                    )
            }

            if let totals = viewModel.usageTotalsDisplay {
                UsageSummaryView(totals: totals, last: viewModel.lastUsageDisplay)
            }

            if viewModel.isStreaming {
                VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
                    ActivityBarView(
                        active: activityStage(from: viewModel.currentPhase),
                        toolName: toolName(from: viewModel.currentPhase)
                    )
                    HStack(spacing: FamiliarSpacing.xs) {
                        BreathingDotView()
                        Text(statusLine(from: viewModel))
                            .font(.familiarCaption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
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
        // Frosted, floating palette styling
        .background(
            RoundedRectangle(cornerRadius: FamiliarRadius.card, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: FamiliarRadius.card, style: .continuous))
        .shadow(color: Color.black.opacity(0.18), radius: 24, x: 0, y: 16)
        // Accent hairline with streaming sheen
        .overlay(alignment: .top) {
            ZStack {
                LinearGradient(
                    colors: [Color.familiarAccent.opacity(0.9), Color.familiarAccent.opacity(0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 2)
                .opacity(viewModel.isStreaming ? 1.0 : 0.6)
                if !reduceMotion && viewModel.isStreaming {
                    HairlineSheen()
                        .frame(height: 2)
                        .transition(.opacity)
                }
            }
            .animation(.familiarContextual, value: viewModel.isStreaming)
        }
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

    private func updateUserAtBottom() {
        guard viewportHeight > 0 else { return }
        let bottomDistance = bottomMaxY - viewportHeight
        userAtBottom = bottomDistance < bottomThreshold
    }
}

// MARK: - Scroll Metrics Preferences
private struct BottomMaxYPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

private struct ViewportHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

private struct HairlineSheen: View {
    @State private var offset: CGFloat = -200
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [
            .white.opacity(0.0),
            .white.opacity(0.6),
            .white.opacity(0.0)
        ]), startPoint: .leading, endPoint: .trailing)
        .blendMode(.screen)
        .opacity(0.35)
        .mask(
            Rectangle()
                .offset(x: offset)
                .frame(width: 120)
        )
        .onAppear {
            withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                offset = 900
            }
        }
    }
}

private func activityStage(from phase: FamiliarViewModel.Phase?) -> ActivityBarView.Stage? {
    guard let phase else { return nil }
    switch phase {
    case .planning: return .planning
    case .tooling: return .tooling
    case .replying: return .replying
    }
}

private func toolName(from phase: FamiliarViewModel.Phase?) -> String? {
    if case let .tooling(name) = phase { return name }
    return nil
}

private func phaseIsPreReply(_ phase: FamiliarViewModel.Phase) -> Bool {
    if case .replying = phase { return false }
    return true
}

@MainActor
private func statusLine(from vm: FamiliarViewModel) -> String {
    switch vm.currentPhase {
    case .planning: return vm.loadingMessage ?? "Thinking it through…"
    case let .tooling(name):
        if let name, !name.isEmpty { return "Using \(name)…" }
        return "Using tools…"
    case .replying: return "Typing…"
    case .none: return vm.loadingMessage ?? "Working on it…"
    }
}
