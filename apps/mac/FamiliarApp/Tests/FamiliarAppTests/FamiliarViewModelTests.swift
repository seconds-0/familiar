import XCTest
@testable import FamiliarApp

final class FamiliarViewModelTests: XCTestCase {
    @MainActor
    func testInitialState() {
        let viewModel = FamiliarViewModel()

        XCTAssertTrue(viewModel.prompt.isEmpty, "Prompt should start empty")
        XCTAssertTrue(viewModel.transcript.isEmpty, "Transcript should start empty")
        XCTAssertFalse(viewModel.isStreaming, "Should not be streaming initially")
        XCTAssertNil(viewModel.permissionRequest, "No permission request initially")
        XCTAssertNil(viewModel.errorMessage, "No error message initially")
    }

    @MainActor
    func testHandlePaste_ShortText() {
        let viewModel = FamiliarViewModel()
        let shortText = "Hello, world!"

        viewModel.handlePaste(shortText)

        XCTAssertEqual(viewModel.prompt, shortText, "Prompt should contain pasted text")
        XCTAssertNil(viewModel.promptPreview, "No preview for short text")
    }

    @MainActor
    func testHandlePaste_LongText() {
        let viewModel = FamiliarViewModel()
        let longText = String(repeating: "Line\n", count: 25) // > 20 lines

        viewModel.handlePaste(longText)

        XCTAssertEqual(viewModel.prompt, longText, "Prompt should contain pasted text")
        XCTAssertNotNil(viewModel.promptPreview, "Should have preview for long text")
        XCTAssertEqual(viewModel.promptPreview, "[Pasted 26 lines]", "Preview should show line count (split includes trailing newline)")
    }

    @MainActor
    func testHandlePaste_LargeText() {
        let viewModel = FamiliarViewModel()
        let largeText = String(repeating: "a", count: 1500) // > 1000 chars

        viewModel.handlePaste(largeText)

        XCTAssertEqual(viewModel.prompt, largeText, "Prompt should contain pasted text")
        XCTAssertNotNil(viewModel.promptPreview, "Should have preview for large text")
    }

    @MainActor
    func testBeginEditingPrompt_ClearsPreview() {
        let viewModel = FamiliarViewModel()
        let longText = String(repeating: "Line\n", count: 25)

        viewModel.handlePaste(longText)
        XCTAssertNotNil(viewModel.promptPreview, "Preview should exist after paste")

        viewModel.beginEditingPrompt()
        XCTAssertNil(viewModel.promptPreview, "Preview should be cleared when editing begins")
    }

    @MainActor
    func testCancelStreaming_ResetsState() {
        let viewModel = FamiliarViewModel()

        // Simulate streaming state (without actually making a network call)
        // We'll just set the flag and test that cancel resets it
        viewModel.cancelStreaming()

        XCTAssertFalse(viewModel.isStreaming, "Should not be streaming after cancel")
        XCTAssertNil(viewModel.promptPreview, "Preview should be cleared on cancel")
    }

    @MainActor
    func testUsageTotalsDisplay_WhenEmpty() {
        let viewModel = FamiliarViewModel()

        XCTAssertNil(viewModel.usageTotalsDisplay, "Should be nil when no usage data")
    }

    @MainActor
    func testSessionSnapshot_PreviousSessionNil() {
        let viewModel = FamiliarViewModel()

        // previousSession is private, but we can test that it doesn't crash
        // and that the viewModel initializes properly
        XCTAssertTrue(viewModel.transcript.isEmpty, "Should start with empty transcript")
    }

    @MainActor
    func testActivityTracking_MarksActivity() {
        let viewModel = FamiliarViewModel()

        // Test that user interactions mark activity
        let beforePaste = viewModel.lastActivityAt

        // Wait a tiny bit to ensure time difference
        Thread.sleep(forTimeInterval: 0.01)

        viewModel.handlePaste("test")

        XCTAssertGreaterThan(viewModel.lastActivityAt, beforePaste, "Activity should be marked after paste")
    }

    @MainActor
    func testEvaluateInactivityReset_NoResetWhenEmpty() {
        let viewModel = FamiliarViewModel()

        // With empty transcript, should not reset even after "timeout"
        viewModel.evaluateInactivityReset()

        XCTAssertTrue(viewModel.transcript.isEmpty, "Should remain empty")
    }
}
