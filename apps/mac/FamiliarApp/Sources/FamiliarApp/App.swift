import AppKit
import SwiftUI
import KeyboardShortcuts

@main
struct FamiliarAppMain: App {
    private let controller = FamiliarWindowController.shared
    @StateObject private var appState = AppState()

    init() {
        if KeyboardShortcuts.getShortcut(for: .summon) == nil {
            KeyboardShortcuts.setShortcut(
                .init(.space, modifiers: [.option]),
                for: .summon
            )
        }

        // Kick off zero-state prewarm independently of the view lifecycle
        Task.detached {
            await ZeroStateCache.shared.prewarm()
        }
    }

    var body: some Scene {
        MenuBarExtra {
            Label(appState.status.label, systemImage: appState.status.systemImage)
            if let detail = appState.statusDetail {
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let workspaceURL = appState.workspaceURL {
                Button("Open Workspace Folder") {
                    NSWorkspace.shared.open(workspaceURL)
                }
            }
            if let demoURL = appState.demoFileURL {
                Button("Open Demo Note") {
                    NSWorkspace.shared.open(demoURL)
                }
            }
            Button("Toggle Familiar") {
                controller.toggle()
            }
            Button("Open Settings…") {
                SettingsWindowController.shared.toggle(appState: appState)
            }
            Button("Refresh Status") {
                appState.refresh()
            }
            Divider()
            Button("Quit") {
                NSApp.terminate(nil)
            }
        } label: {
            MenuBarIconView()
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(appState: appState)
                .environmentObject(appState)
        }
    }
}
