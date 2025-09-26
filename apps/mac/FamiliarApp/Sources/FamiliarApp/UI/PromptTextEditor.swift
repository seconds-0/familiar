import AppKit
import SwiftUI

struct PromptTextEditor: View {
    @Binding var text: String
    let preview: String?
    let onSubmit: () -> Void
    let onPaste: (String) -> Void
    let onBeginEditing: () -> Void

    @State private var contentHeight: CGFloat = 0
    @State private var isEditing: Bool = false

    private let maxVisibleLines: CGFloat = 4
    private let textInsets = NSSize(width: 12, height: 8)
    private let font = NSFont.preferredFont(forTextStyle: .body)

    private var lineHeight: CGFloat { ceil(font.ascender - font.descender + font.leading) }
    private var minimumHeight: CGFloat { lineHeight + textInsets.height * 2 }
    private var maximumHeight: CGFloat { minimumHeight + lineHeight * (maxVisibleLines - 1) }

    private var dynamicHeight: CGFloat {
        let baseHeight = max(contentHeight, minimumHeight)
        return min(baseHeight, maximumHeight)
    }

    private var placeholder: String {
        if let preview, !preview.isEmpty {
            return preview
        }
        return "Ask your Familiar to do something…"
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            PromptTextViewRepresentable(
                text: $text,
                contentHeight: $contentHeight,
                isEditing: $isEditing,
                minimumHeight: minimumHeight,
                font: font,
                textInsets: textInsets,
                onSubmit: onSubmit,
                onPaste: onPaste,
                onBeginEditing: onBeginEditing
            )
            .frame(height: dynamicHeight)
            .animation(.easeInOut(duration: 0.15), value: dynamicHeight)

            if text.isEmpty && !isEditing {
                Text(placeholder)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.top, textInsets.height)
                    .padding(.leading, textInsets.width)
                    .allowsHitTesting(false)
                    .opacity(isEditing ? 0 : 1)
                    .animation(.easeInOut(duration: 0.1), value: isEditing)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PromptTextViewRepresentable: NSViewRepresentable {
    @Binding var text: String
    @Binding var contentHeight: CGFloat
    @Binding var isEditing: Bool
    let minimumHeight: CGFloat
    let font: NSFont
    let textInsets: NSSize
    let onSubmit: () -> Void
    let onPaste: (String) -> Void
    let onBeginEditing: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            text: $text,
            contentHeight: $contentHeight,
            isEditing: $isEditing,
            minimumHeight: minimumHeight,
            onSubmit: onSubmit,
            onPaste: onPaste,
            onBeginEditing: onBeginEditing
        )
    }

    func makeNSView(context: Context) -> NSScrollView {
        let (scrollView, textView) = PromptNSTextView.makeHostingScrollView()

        textView.string = text
        configure(textView: textView, coordinator: context.coordinator)
        context.coordinator.textView = textView
        context.coordinator.updateContentHeight()
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = context.coordinator.textView else { return }

        context.coordinator.isUpdatingFromParent = true
        if textView.string != text {
            textView.string = text
        }
        context.coordinator.isUpdatingFromParent = false

        configure(textView: textView, coordinator: context.coordinator)
        context.coordinator.updateContentHeight()

        if context.environment.isFocused {
            DispatchQueue.main.async {
                textView.window?.makeFirstResponder(textView)
            }
        }
    }

    private func configure(textView: PromptNSTextView, coordinator: Coordinator) {
        textView.applyPromptStyling(font: font, textInsets: textInsets, minimumHeight: minimumHeight)

        textView.returnKeyHandler = { modifiers in
            if modifiers.contains(.shift) {
                onBeginEditing()
                textView.insertNewline(nil)
            } else {
                onSubmit()
            }
        }
        textView.beginEditingHandler = {
            coordinator.isEditing.wrappedValue = true
            onBeginEditing()
        }
        textView.endEditingHandler = {
            coordinator.isEditing.wrappedValue = false
        }
        textView.pasteHandler = { value in
            onPaste(value)
        }

        if textView.delegate !== coordinator {
            textView.delegate = coordinator
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        private let textBinding: Binding<String>
        private let contentHeightBinding: Binding<CGFloat>
        let isEditing: Binding<Bool>
        private let minimumHeight: CGFloat
        private let onSubmit: () -> Void
        private let onPaste: (String) -> Void
        private let onBeginEditing: () -> Void

        weak var textView: PromptNSTextView?
        var isUpdatingFromParent = false
        private var heightUpdateTimer: Timer?

        init(
            text: Binding<String>,
            contentHeight: Binding<CGFloat>,
            isEditing: Binding<Bool>,
            minimumHeight: CGFloat,
            onSubmit: @escaping () -> Void,
            onPaste: @escaping (String) -> Void,
            onBeginEditing: @escaping () -> Void
        ) {
            textBinding = text
            contentHeightBinding = contentHeight
            self.isEditing = isEditing
            self.minimumHeight = minimumHeight
            self.onSubmit = onSubmit
            self.onPaste = onPaste
            self.onBeginEditing = onBeginEditing
        }

        deinit {
            heightUpdateTimer?.invalidate()
        }

        func textDidChange(_ notification: Notification) {
            guard !isUpdatingFromParent, let textView else { return }
            textBinding.wrappedValue = textView.string
            scheduleHeightUpdate()
        }

        private func scheduleHeightUpdate() {
            heightUpdateTimer?.invalidate()
            heightUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { _ in
                DispatchQueue.main.async {
                    self.updateContentHeight()
                }
            }
        }

        func updateContentHeight() {
            guard let textView = textView else { return }

            let newHeight = calculatePromptContentHeight(textView: textView, minimumHeight: minimumHeight)

            // Only update if height changed significantly to prevent jitter
            let currentHeight = contentHeightBinding.wrappedValue
            if abs(newHeight - currentHeight) > 1.0 {
                contentHeightBinding.wrappedValue = newHeight
            }
        }
    }
}

final class PromptNSTextView: NSTextView {
    var returnKeyHandler: ((NSEvent.ModifierFlags) -> Void)?
    var beginEditingHandler: (() -> Void)?
    var endEditingHandler: (() -> Void)?
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
        backgroundColor = .textBackgroundColor
        drawsBackground = true
        wantsLayer = true
        layer?.cornerRadius = 10
        layer?.masksToBounds = true
        layer?.backgroundColor = NSColor.textBackgroundColor.cgColor
        layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.4).cgColor
        layer?.borderWidth = 1
    }
}

func calculatePromptContentHeight(textView: NSTextView, minimumHeight: CGFloat) -> CGFloat {
    let font = textView.font ?? NSFont.preferredFont(forTextStyle: .body)
    let lineHeight = ceil(font.ascender - font.descender + font.leading)
    let maxVisibleLines: CGFloat = 4
    let maximumHeight = minimumHeight + lineHeight * (maxVisibleLines - 1)

    guard let textContainer = textView.textContainer,
          let layoutManager = textView.layoutManager else {
        return minimumHeight
    }

    layoutManager.ensureLayout(for: textContainer)
    let usedRect = layoutManager.usedRect(for: textContainer)
    let contentHeight = usedRect.height + textView.textContainerInset.height * 2
    let clampedHeight = max(contentHeight, minimumHeight)
    return min(clampedHeight, maximumHeight)
}
