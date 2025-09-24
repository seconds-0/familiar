import AppKit
import KeyboardShortcuts
import SwiftUI

final class FamiliarWindowController: NSObject, ObservableObject {
    static let shared = FamiliarWindowController()

    private lazy var hostingController = NSHostingController(rootView: FamiliarView())
    private lazy var panel: NSPanel = {
        let panel = NSPanel(contentViewController: hostingController)
        panel.titleVisibility = .hidden
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.styleMask = [.nonactivatingPanel, .titled, .fullSizeContentView]
        panel.level = .statusBar
        panel.collectionBehavior = [.fullScreenAuxiliary, .canJoinAllSpaces]
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
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 8) {
                TextField("Ask Claude Code…", text: $viewModel.prompt)
                    .focused($isPromptFocused)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { viewModel.submit() }
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

            if viewModel.isStreaming {
                ProgressView().progressViewStyle(.linear)
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
    }
}
