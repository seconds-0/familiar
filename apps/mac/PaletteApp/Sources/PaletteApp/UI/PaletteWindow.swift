import AppKit
import SwiftUI
import KeyboardShortcuts

final class PaletteWindowController: NSObject, ObservableObject {
    static let shared = PaletteWindowController()

    private var window: NSPanel?
    private let hostingController = NSHostingController(rootView: PaletteView())

    private override init() {
        super.init()
        setupWindow()
        KeyboardShortcuts.onKeyUp(for: .summon) { [weak self] in
            self?.toggle()
        }
    }

    private func setupWindow() {
        let panel = NSPanel(contentViewController: hostingController)
        panel.titleVisibility = .hidden
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.styleMask = [.nonactivatingPanel, .titled, .fullSizeContentView]
        panel.level = .statusBar
        window = panel
    }

    func toggle() {
        guard let window else { return }
        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.center()
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

struct PaletteView: View {
    @State private var prompt = ""
    @State private var transcript = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Ask Claude Code…", text: $prompt, onCommit: runQuery)
                .textFieldStyle(.roundedBorder)
            ScrollView {
                Text(transcript)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
        }
        .padding(20)
        .frame(width: 720, height: 440)
    }

    private func runQuery() {
        Task {
            transcript = ""
            for await chunk in SidecarClient.shared.stream(prompt: prompt) {
                transcript.append(contentsOf: chunk)
            }
        }
    }
}
