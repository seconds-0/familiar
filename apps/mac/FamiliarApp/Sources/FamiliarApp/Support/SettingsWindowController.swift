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
            createWindow(appState: appState)
        } else {
            updateWindow(appState: appState)
        }

        guard let window else { return }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
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

    private func createWindow(appState: AppState) {
        let hostingController = NSHostingController(rootView: rootView(for: appState))

        let window = SettingsWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 360),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Familiar Settings"
        window.center()
        window.isReleasedWhenClosed = false
        window.contentViewController = hostingController
        window.delegate = self

        self.window = window
    }

    private func updateWindow(appState: AppState) {
        guard let window else {
            self.window = nil
            createWindow(appState: appState)
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
            SettingsView(onClose: { [weak self] in
                self?.close()
            })
            .environmentObject(appState)
        )
    }
}
