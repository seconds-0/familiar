import AppKit
import SwiftUI

private final class SettingsWindow: NSWindow {
    override func cancelOperation(_ sender: Any?) {
        performClose(sender)
    }
}

final class SettingsWindowController: NSObject, NSWindowDelegate {
    static let shared = SettingsWindowController()

    private var window: NSWindow?

    private override init() {
        super.init()
    }

    func show(appState: AppState) {
        if window == nil {
            createWindow()
        }

        guard let window else { return }
        // Bring the window forward immediately to avoid any async work (like Keychain prompts)
        // preventing the user from seeing the Settings UI appear.
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)

        // Populate/update content after the window is visible.
        updateWindow(appState: appState)
    }

    func toggle(appState: AppState) {
        if let window, window.isVisible {
            close()
        } else {
            show(appState: appState)
        }
    }

    func close() {
        window?.performClose(nil)
    }

    private func createWindow() {
        let window = SettingsWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 360),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Familiar Settings"
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self

        self.window = window
    }

    private func updateWindow(appState: AppState) {
        guard let window else {
            self.window = nil
            createWindow()
            return
        }
        if let hostingController = window.contentViewController as? NSHostingController<AnyView> {
            hostingController.rootView = rootView(for: appState)
        } else {
            window.contentViewController = NSHostingController(rootView: rootView(for: appState))
        }
    }

    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow, window == self.window else { return }
        self.window = nil
    }

    private func rootView(for appState: AppState) -> AnyView {
        AnyView(
            SettingsView()
            .environmentObject(appState)
        )
    }
}
