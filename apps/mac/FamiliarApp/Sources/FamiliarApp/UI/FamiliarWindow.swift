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
        panel.styleMask = [.nonactivatingPanel, .titled, .fullSizeContentView]
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
        DispatchQueue.main.async {
            let window = self.panel
            if window.isVisible {
                window.orderOut(nil)
            } else {
                window.center()
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}

struct FamiliarView: View {
    @StateObject private var viewModel = FamiliarViewModel()
    @FocusState private var isPromptFocused: Bool

    var body: some View {
        VStack(spacing: 12) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
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
            }

            if let totals = viewModel.usageTotalsDisplay {
                UsageSummaryView(totals: totals, last: viewModel.lastUsageDisplay)
            }

            if viewModel.isStreaming {
                HStack(spacing: 8) {
                    ProgressView().progressViewStyle(.circular)
                    Text(viewModel.loadingMessage ?? "Working on it…")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 8) {
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
                            Image(systemName: "stop.circle.fill")
                        }
                        .buttonStyle(.bordered)
                        .help("Stop current request")
                    } else {
                        Button {
                            viewModel.submit()
                        } label: {
                            Image(systemName: "paperplane.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .help("Send prompt")
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
        .padding(20)
        .frame(width: 720, height: 460)
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
