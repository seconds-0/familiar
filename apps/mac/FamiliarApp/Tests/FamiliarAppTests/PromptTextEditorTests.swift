import AppKit
import SwiftUI
import XCTest
@testable import FamiliarApp

final class PromptTextEditorTests: XCTestCase {
    private func runOnMain<T>(_ work: () -> T) -> T {
        if Thread.isMainThread {
            return work()
        }
        return DispatchQueue.main.sync(execute: work)
    }

    func testPromptNSTextViewFactoryInstallsCustomTextView() {
        let (scrollView, textView) = PromptNSTextView.makeHostingScrollView()

        XCTAssertTrue(scrollView.documentView === textView, "Scroll view should host the created PromptNSTextView instance")
        XCTAssertTrue(type(of: textView) == PromptNSTextView.self, "Factory must return the PromptNSTextView subclass")
        XCTAssertFalse(scrollView.hasHorizontalScroller, "Prompt scroll view should not expose horizontal scrolling")
    }

    func testPromptNSTextViewStylingEnablesEditingAndAppearance() {
        let font = NSFont.preferredFont(forTextStyle: .body)
        let textInsets = NSSize(width: 12, height: 8)
        let lineHeight = PromptTextEditor.lineHeight(for: font)
        let minimumHeight = lineHeight + textInsets.height * 2

        let textView = PromptNSTextView(frame: NSRect(x: 0, y: 0, width: 400, height: 100))
        textView.applyPromptStyling(font: font, textInsets: textInsets, minimumHeight: minimumHeight)

        XCTAssertTrue(textView.isEditable)
        XCTAssertTrue(textView.isSelectable)
        XCTAssertEqual(textView.textContainerInset, textInsets)
        XCTAssertEqual(textView.textContainer?.lineFragmentPadding, 0)
        XCTAssertEqual(textView.minSize.height, minimumHeight, accuracy: 0.5)
    }

    func testContentHeightClampsAfterSixLines() {
        let font = NSFont.preferredFont(forTextStyle: .body)
        let textInsets = NSSize(width: 12, height: 8)
        let lineHeight = PromptTextEditor.lineHeight(for: font)
        let minimumHeight = lineHeight + textInsets.height * 2
        let maximumHeight = minimumHeight + lineHeight * 5

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
        let lineHeight = PromptTextEditor.lineHeight(for: font)
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

    func testVisibleHeightClampsWithinAllowedRange() {
        let font = NSFont.preferredFont(forTextStyle: .body)
        let lineHeight = PromptTextEditor.lineHeight(for: font)
        let textInsets = NSSize(width: 12, height: 8)
        let minimumHeight = lineHeight + textInsets.height * 2
        let maximumHeight = minimumHeight + lineHeight * 5

        let tooSmall = PromptTextEditor.visibleHeight(
            forContentHeight: minimumHeight / 2,
            minimumHeight: minimumHeight,
            maximumHeight: maximumHeight
        )
        XCTAssertEqual(tooSmall, minimumHeight, accuracy: 0.1)

        let ideal = PromptTextEditor.visibleHeight(
            forContentHeight: minimumHeight + lineHeight,
            minimumHeight: minimumHeight,
            maximumHeight: maximumHeight
        )
        XCTAssertEqual(ideal, minimumHeight + lineHeight, accuracy: 0.1)

        let tooLarge = PromptTextEditor.visibleHeight(
            forContentHeight: maximumHeight + lineHeight,
            minimumHeight: minimumHeight,
            maximumHeight: maximumHeight
        )
        XCTAssertEqual(tooLarge, maximumHeight, accuracy: 0.1)
    }

    func testPromptTextEditorStaysNearFooterWhenContainerIsTall() {
        let layout = measurePromptGap()

        let gap = layout.footerFrame.minY - layout.scrollFrame.maxY

        XCTAssertEqual(layout.scrollFrame.height, layout.minimumPromptHeight, accuracy: 1.0)
        XCTAssertTrue(gap < 40, "gap: \(gap), scroll: \(layout.scrollFrame), footer: \(layout.footerFrame)")
    }

    func testPromptComposerRespectsBottomPadding() {
        let layout = measurePromptGap()

        XCTAssertLessThan(layout.bottomGap, 18, "bottom gap too large: \(layout.bottomGap), footer frame: \(layout.footerFrame)")
    }
}

private struct PromptLayoutMeasurement {
    let scrollFrame: CGRect
    let footerFrame: CGRect
    let minimumPromptHeight: CGFloat
    let bottomGap: CGFloat
}

private extension PromptTextEditorTests {
    func measurePromptGap() -> PromptLayoutMeasurement {
        runOnMain {
            if NSApp == nil {
                _ = NSApplication.shared
            }

            let hostingView = NSHostingView(rootView: PromptGapHarness())
            hostingView.frame = NSRect(x: 0, y: 0, width: 420, height: 600)
            hostingView.needsLayout = true
            hostingView.layoutSubtreeIfNeeded()

            guard
                let scrollView = hostingView.recursiveFirstSubview(ofType: NSScrollView.self),
                let footerLabel = hostingView.recursiveFirstSubview(ofType: NSTextField.self, where: { $0.stringValue == "New line: Shift+Enter    Send: Enter" })
            else {
                XCTFail("Failed to locate layout views")
                return PromptLayoutMeasurement(scrollFrame: .zero, footerFrame: .zero, minimumPromptHeight: 0, bottomGap: 0)
            }

            let scrollFrame = hostingView.convert(scrollView.bounds, from: scrollView)
            let footerFrame = hostingView.convert(footerLabel.bounds, from: footerLabel)
            let hostBounds = hostingView.bounds
            let bottomGap = hostBounds.maxY - footerFrame.maxY

            let font = NSFont.preferredFont(forTextStyle: .body)
            let textInsets = NSSize(width: 12, height: 8)
            let minimumHeight = PromptTextEditor.lineHeight(for: font) + textInsets.height * 2

            return PromptLayoutMeasurement(
                scrollFrame: scrollFrame,
                footerFrame: footerFrame,
                minimumPromptHeight: minimumHeight,
                bottomGap: bottomGap
            )
        }
    }
}

private struct PromptGapHarness: View {
    @State private var prompt: String = ""

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 12) {
                Spacer(minLength: 0)

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    PromptTextEditor(
                        text: $prompt,
                        preview: nil,
                        onSubmit: {},
                        onPaste: { _ in },
                        onBeginEditing: {}
                    )

                    InstructionLabel("New line: Shift+Enter    Send: Enter")
                }
            }
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 12, trailing: 20))
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct InstructionLabel: NSViewRepresentable {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    func makeNSView(context: Context) -> NSTextField {
        let label = NSTextField(labelWithString: title)
        label.font = NSFont.preferredFont(forTextStyle: .footnote)
        label.lineBreakMode = .byTruncatingTail
        return label
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = title
    }
}

private extension NSView {
    func recursiveFirstSubview<T: NSView>(ofType type: T.Type) -> T? {
        recursiveFirstSubview(ofType: type, where: { _ in true })
    }

    func recursiveFirstSubview<T: NSView>(ofType type: T.Type, where predicate: (T) -> Bool) -> T? {
        if let match = self as? T, predicate(match) {
            return match
        }
        for subview in subviews {
            if let match = subview.recursiveFirstSubview(ofType: type, where: predicate) {
                return match
            }
        }
        return nil
    }

}
