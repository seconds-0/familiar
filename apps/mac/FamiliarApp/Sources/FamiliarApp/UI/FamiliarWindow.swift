import AppKit
import KeyboardShortcuts
import SwiftUI

private final class FamiliarPanel: NSPanel {
    override func cancelOperation(_ sender: Any?) {
        orderOut(sender)
    }
}
final class FamiliarWindowController: NSObject, ObservableObject {
    static let shared = FamiliarWindowController()

    private lazy var hostingController = NSHostingController(rootView: FamiliarView())
    private lazy var panel: NSPanel = {
        let panel = FamiliarPanel(contentViewController: hostingController)
        panel.titleVisibility = .hidden
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.styleMask = [.nonactivatingPanel, .titled, .fullSizeContentView, .closable]
        panel.level = .statusBar
        panel.collectionBehavior = [.fullScreenAuxiliary, .canJoinAllSpaces]
        panel.isReleasedWhenClosed = false
        return panel
    }()

    private override init() {
        super.init()
        KeyboardShortcuts.onKeyUp(for: .summon) { [weak self] in
            self?.toggle()
        }
    }

    func toggle() {
        let window = panel
        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.center()
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

struct FamiliarView: View {
    @StateObject private var viewModel = FamiliarViewModel()
    @FocusState private var isPromptFocused: Bool

    var body: some View {
        VStack(spacing: FamiliarSpacing.sm) {
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(alignment: .leading, spacing: FamiliarSpacing.sm) {
                    if !viewModel.transcript.isEmpty {
                        Text(viewModel.transcript)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }

                    if let summary = viewModel.toolSummary {
                        ToolSummaryView(summary: summary)
                    }

                    if let error = viewModel.errorMessage {
                        Label(error, systemImage: "exclamationmark.circle")
                            .foregroundStyle(.red)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 1) // Prevent content from touching scroll edges
            }
            .frame(maxHeight: 300) // Allow scrolling when content is large

            if let totals = viewModel.usageTotalsDisplay {
                UsageSummaryView(totals: totals, last: viewModel.lastUsageDisplay)
            }

            if viewModel.isStreaming {
                HStack(spacing: FamiliarSpacing.xs) {
                    BreathingDotView()
                    Text(viewModel.loadingMessage ?? "Working on it…")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            Divider()

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
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
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
            minHeight: 400,
            idealHeight: 460,
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
        .onAppear {
            isPromptFocused = true
        }
        .onExitCommand {
            FamiliarWindowController.shared.toggle()
        }
    }
}
