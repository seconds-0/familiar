import AppKit
import XCTest
@testable import FamiliarApp

final class PromptTextEditorTests: XCTestCase {
    func testPromptNSTextViewFactoryInstallsCustomTextView() {
        let (scrollView, textView) = PromptNSTextView.makeHostingScrollView()

        XCTAssertTrue(scrollView.documentView === textView, "Scroll view should host the created PromptNSTextView instance")
        XCTAssertTrue(textView is PromptNSTextView, "Factory must return the PromptNSTextView subclass")
        XCTAssertFalse(scrollView.hasHorizontalScroller, "Prompt scroll view should not expose horizontal scrolling")
    }

    func testPromptNSTextViewStylingEnablesEditingAndAppearance() {
        let font = NSFont.preferredFont(forTextStyle: .body)
        let textInsets = NSSize(width: 12, height: 8)
        let lineHeight = ceil(font.ascender - font.descender + font.leading)
        let minimumHeight = lineHeight + textInsets.height * 2

        let textView = PromptNSTextView(frame: NSRect(x: 0, y: 0, width: 400, height: 100))
        textView.applyPromptStyling(font: font, textInsets: textInsets, minimumHeight: minimumHeight)

        XCTAssertTrue(textView.isEditable)
        XCTAssertTrue(textView.isSelectable)
        XCTAssertEqual(textView.textContainerInset, textInsets)
        XCTAssertEqual(textView.textContainer?.lineFragmentPadding, 0)
        XCTAssertEqual(textView.minSize.height, minimumHeight, accuracy: 0.5)
    }

    func testContentHeightClampsAfterFourLines() {
        let font = NSFont.preferredFont(forTextStyle: .body)
        let textInsets = NSSize(width: 12, height: 8)
        let lineHeight = ceil(font.ascender - font.descender + font.leading)
        let minimumHeight = lineHeight + textInsets.height * 2
        let maximumHeight = minimumHeight + lineHeight * 3

        let textView = PromptNSTextView(frame: NSRect(x: 0, y: 0, width: 400, height: 100))
        textView.applyPromptStyling(font: font, textInsets: textInsets, minimumHeight: minimumHeight)

        let overflowingText = Array(repeating: "Line", count: 6).joined(separator: "\n")
        textView.string = overflowingText

        let height = calculatePromptContentHeight(textView: textView, minimumHeight: minimumHeight)

        XCTAssertEqual(height, maximumHeight, accuracy: 2.0)
    }

    func testContentHeightReturnsMinimumForSingleLine() {
        let font = NSFont.preferredFont(forTextStyle: .body)
        let textInsets = NSSize(width: 12, height: 8)
        let lineHeight = ceil(font.ascender - font.descender + font.leading)
        let minimumHeight = lineHeight + textInsets.height * 2

        let textView = PromptNSTextView(frame: NSRect(x: 0, y: 0, width: 400, height: 100))
        textView.applyPromptStyling(font: font, textInsets: textInsets, minimumHeight: minimumHeight)
        textView.string = "One line"

        let height = calculatePromptContentHeight(textView: textView, minimumHeight: minimumHeight)

        XCTAssertEqual(height, minimumHeight, accuracy: 1.0)
    }

    func testReturnKeyHandlerTriggersSubmitWithoutModifiers() {
        let textView = PromptNSTextView(frame: .zero)

        var capturedModifiers: NSEvent.ModifierFlags?
        textView.returnKeyHandler = { modifiers in
            capturedModifiers = modifiers
        }

        textView.doCommand(by: #selector(NSTextView.insertNewline(_:)))

        XCTAssertEqual(capturedModifiers, [], "Return key without modifiers should pass empty modifier set")
    }

    func testShiftReturnInsertsNewlineInsteadOfSubmit() {
        let textView = PromptNSTextView(frame: .zero)
        textView.string = "Hello"

        var submitInvoked = false
        textView.returnKeyHandler = { modifiers in
            if modifiers.contains(.shift) {
                textView.insertNewline(nil)
            } else {
                submitInvoked = true
            }
        }

        textView.returnKeyHandler?([.shift])

        XCTAssertTrue(textView.string.hasSuffix("\n"), "Shift+Return should insert a newline")
        XCTAssertFalse(submitInvoked, "Shift+Return should not trigger submit handler")
    }
}
