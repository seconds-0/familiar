import AppKit
import SwiftUI
import KeyboardShortcuts

@main
struct PaletteAppMain: App {
    @StateObject private var controller = PaletteWindowController.shared
    @StateObject private var appState = AppState()

    init() {
        if KeyboardShortcuts.getShortcut(for: .summon) == nil {
            KeyboardShortcuts.setShortcut(
                .init(.space, modifiers: [.option]),
                for: .summon
            )
        }
    }

    var body: some Scene {
        MenuBarExtra("Palette", systemImage: "sparkles") {
            Label(appState.status.label, systemImage: appState.status.systemImage)
            Button("Toggle Palette") {
                PaletteWindowController.shared.toggle()
            }
            Button("Open Settings…") {
                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
            }
            Button("Refresh Status") {
                appState.refresh()
            }
            Divider()
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
        }
    }
}
