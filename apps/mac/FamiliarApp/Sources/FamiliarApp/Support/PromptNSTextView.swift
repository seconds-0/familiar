import AppKit

/// Custom NSTextView for prompt input with specialized behavior
///
/// Provides callback-based event handling for return key, editing lifecycle,
/// and paste operations. Used by PromptTextEditor's NSViewRepresentable wrapper.
final class PromptNSTextView: NSTextView {
    /// Callback invoked when return key is pressed, providing modifier flags
    var returnKeyHandler: ((NSEvent.ModifierFlags) -> Void)?

    /// Callback invoked when text view becomes first responder
    var beginEditingHandler: (() -> Void)?

    /// Callback invoked when text view resigns first responder
    var endEditingHandler: (() -> Void)?

    /// Callback invoked when paste operation occurs, providing pasted string
    var pasteHandler: ((String) -> Void)?

    override func doCommand(by selector: Selector) {
        if selector == #selector(insertNewline(_:)) {
            returnKeyHandler?(window?.currentEvent?.modifierFlags ?? [])
        } else {
            super.doCommand(by: selector)
        }
    }

    override func becomeFirstResponder() -> Bool {
        let became = super.becomeFirstResponder()
        if became {
            beginEditingHandler?()
        }
        return became
    }

    override func resignFirstResponder() -> Bool {
        let resigned = super.resignFirstResponder()
        if resigned {
            endEditingHandler?()
        }
        return resigned
    }

    override func paste(_ sender: Any?) {
        if let pasteboard = NSPasteboard.general.string(forType: .string) {
            pasteHandler?(pasteboard)
        }
        super.paste(sender)
    }

    /// Create a scrollable text view configured for prompt input
    ///
    /// - Returns: Tuple of (scroll view, text view) ready for use
    static func makeHostingScrollView() -> (NSScrollView, PromptNSTextView) {
        let scrollView = NSTextView.scrollableTextView()
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = false

        let textViewFrame = scrollView.documentView?.frame ?? .zero
        let textView = PromptNSTextView(frame: textViewFrame)
        textView.autoresizingMask = scrollView.documentView?.autoresizingMask ?? [.width]
        scrollView.documentView = textView

        return (scrollView, textView)
    }

    /// Apply prompt-specific styling and configuration
    ///
    /// Configures the text view for single-line expandable input with
    /// appropriate typography and layout settings.
    ///
    /// - Parameters:
    ///   - font: Font to use for text
    ///   - textInsets: Padding around text content
    ///   - minimumHeight: Minimum height for the text view
    func applyPromptStyling(font: NSFont, textInsets: NSSize, minimumHeight: CGFloat) {
        isEditable = true
        isSelectable = true
        allowsUndo = true
        self.font = font
        textColor = NSColor.labelColor
        insertionPointColor = NSColor.labelColor
        isRichText = false
        usesFontPanel = false
        usesFindBar = true
        importsGraphics = false
        textContainerInset = textInsets
        textContainer?.lineFragmentPadding = 0
        maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        isVerticallyResizable = true
        isHorizontallyResizable = false
        textContainer?.widthTracksTextView = true
        minSize = NSSize(width: 0, height: minimumHeight)
        autoresizingMask = [.width]
        drawsBackground = false
        backgroundColor = .clear
        wantsLayer = false
    }
}

/// Calculate content height for prompt text view with line clamping
///
/// Computes the natural height of the text view's content, clamped to a maximum
/// of 6 visible lines. Used for dynamic height adjustment as user types.
///
/// - Parameters:
///   - textView: The text view to measure
///   - minimumHeight: Minimum height to return
/// - Returns: Calculated height clamped to reasonable bounds
func calculatePromptContentHeight(textView: NSTextView, minimumHeight: CGFloat) -> CGFloat {
    let font = textView.font ?? NSFont.preferredFont(forTextStyle: .body)
    let lineHeight = ceil(NSAttributedString(string: "Hg", attributes: [.font: font]).size().height)
    let maxVisibleLines: CGFloat = 6
    let maximumHeight = minimumHeight + lineHeight * (maxVisibleLines - 1)

    guard let textContainer = textView.textContainer,
          let layoutManager = textView.layoutManager else {
        return minimumHeight
    }

    layoutManager.ensureLayout(for: textContainer)
    let usedRect = layoutManager.usedRect(for: textContainer)
    let contentHeight = usedRect.height + textView.textContainerInset.height * 2
    let baseHeight: CGFloat
    if contentHeight <= 0 {
        baseHeight = minimumHeight
    } else if usedRect.height <= lineHeight + 0.5 {
        baseHeight = minimumHeight
    } else {
        baseHeight = contentHeight
    }
    let clampedHeight = max(baseHeight, minimumHeight)
    return min(clampedHeight, maximumHeight)
}