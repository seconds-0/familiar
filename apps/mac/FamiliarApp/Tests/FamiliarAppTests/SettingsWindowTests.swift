import AppKit
import XCTest
@testable import FamiliarApp

final class SettingsWindowTests: XCTestCase {
    override func setUp() {
        super.setUp()
        if NSApp == nil {
            _ = NSApplication.shared
        }
    }

    @MainActor
    func testToggleOpensSettingsWindow() {
        let appState = AppState(startMonitoring: false)
        SettingsWindowController.shared.toggle(appState: appState)

        // Allow the runloop a brief moment to create and present the window
        RunLoop.current.run(until: Date().addingTimeInterval(0.05))

        let hasSettings = NSApp.windows.contains { $0.title == "Familiar Settings" && $0.isVisible }
        XCTAssertTrue(hasSettings, "Settings window should be visible after toggle")

        // Clean up
        SettingsWindowController.shared.close()
    }
}
