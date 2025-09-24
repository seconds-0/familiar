import AppKit
import SwiftUI
import KeyboardShortcuts

@main
struct PaletteAppMain: App {
    @StateObject private var controller = PaletteWindowController.shared

    init() {
        KeyboardShortcuts.setShortcut(
            .init(.space, modifiers: [.option]),
            for: .summon
        )
    }

    var body: some Scene {
        MenuBarExtra("Palette", systemImage: "sparkles") {
            Button("Toggle Palette") {
                PaletteWindowController.shared.toggle()
            }
            Divider()
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }

        Settings {
            SettingsView()
        }
    }
}
