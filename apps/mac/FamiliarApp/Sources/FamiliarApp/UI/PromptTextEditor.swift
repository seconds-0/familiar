import AppKit
import SwiftUI

struct PromptTextEditor: View {
    @Binding var text: String
    let preview: String?
    let onSubmit: () -> Void
    let onPaste: (String) -> Void
    let onBeginEditing: () -> Void

    @State private var measuredHeight: CGFloat = 0

    private let maxVisibleLines: CGFloat = 4
    private let textInsets = NSSize(width: 12, height: 8)
    private let font = NSFont.preferredFont(forTextStyle: .body)

    private var lineHeight: CGFloat { ceil(font.ascender - font.descender + font.leading) }
    private var minimumHeight: CGFloat { lineHeight + textInsets.height * 2 }
    private var maximumHeight: CGFloat { minimumHeight + lineHeight * (maxVisibleLines - 1) }

    private var placeholder: String {
        if let preview, !preview.isEmpty {
            return preview
        }
        return "Ask your Familiar to do something…"
    }

    var body: some View {
        let clampedHeight = min(max(measuredHeight, minimumHeight), maximumHeight)

        return ZStack(alignment: .topLeading) {
            PromptTextViewRepresentable(
                text: $text,
                measuredHeight: $measuredHeight,
                minimumHeight: minimumHeight,
                font: font,
                textInsets: textInsets,
                onSubmit: onSubmit,
                onPaste: onPaste,
                onBeginEditing: onBeginEditing
            )
            .frame(height: clampedHeight)

            if text.isEmpty {
                Text(placeholder)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.top, textInsets.height)
                    .padding(.leading, textInsets.width)
                    .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PromptTextViewRepresentable: NSViewRepresentable {
    @Binding var text: String
    @Binding var measuredHeight: CGFloat
    let minimumHeight: CGFloat
    let font: NSFont
    let textInsets: NSSize
    let onSubmit: () -> Void
    let onPaste: (String) -> Void
    let onBeginEditing: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            text: $text,
            measuredHeight: $measuredHeight,
            minimumHeight: minimumHeight,
            onSubmit: onSubmit,
            onPaste: onPaste,
            onBeginEditing: onBeginEditing
        )
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false

        guard let textView = scrollView.documentView as? PromptNSTextView else {
            fatalError("Expected PromptNSTextView")
        }

        configure(textView: textView, coordinator: context.coordinator)
        context.coordinator.textView = textView
        context.coordinator.updateHeight()
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
        context.coordinator.updateHeight()

        if context.environment.isFocused {
            DispatchQueue.main.async {
                textView.window?.makeFirstResponder(textView)
            }
        }
    }

    private func configure(textView: PromptNSTextView, coordinator: Coordinator) {
        textView.font = font
        textView.textColor = NSColor.labelColor
        textView.insertionPointColor = NSColor.labelColor
        textView.isRichText = false
        textView.usesFontPanel = false
        textView.usesFindBar = true
        textView.importsGraphics = false
        textView.textContainerInset = textInsets
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.widthTracksTextView = true
        textView.backgroundColor = .textBackgroundColor
        textView.drawsBackground = true
        textView.wantsLayer = true
        textView.layer?.cornerRadius = 10
        textView.layer?.masksToBounds = true
        textView.layer?.backgroundColor = NSColor.textBackgroundColor.cgColor
        textView.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.4).cgColor
        textView.layer?.borderWidth = 1

        textView.returnKeyHandler = { modifiers in
            if modifiers.contains(.shift) {
                onBeginEditing()
                textView.insertNewline(nil)
            } else {
                onSubmit()
            }
        }
        textView.beginEditingHandler = {
            onBeginEditing()
        }
        textView.pasteHandler = { value in
            onPaste(value)
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        private let textBinding: Binding<String>
        private let heightBinding: Binding<CGFloat>
        private let minimumHeight: CGFloat
        private let onSubmit: () -> Void
        private let onPaste: (String) -> Void
        private let onBeginEditing: () -> Void

        weak var textView: PromptNSTextView?
        var isUpdatingFromParent = false

        init(
            text: Binding<String>,
            measuredHeight: Binding<CGFloat>,
            minimumHeight: CGFloat,
            onSubmit: @escaping () -> Void,
            onPaste: @escaping (String) -> Void,
            onBeginEditing: @escaping () -> Void
        ) {
            textBinding = text
            heightBinding = measuredHeight
            self.minimumHeight = minimumHeight
            self.onSubmit = onSubmit
            self.onPaste = onPaste
            self.onBeginEditing = onBeginEditing
        }

        func textDidChange(_ notification: Notification) {
            guard !isUpdatingFromParent, let textView else { return }
            textBinding.wrappedValue = textView.string
            updateHeight()
        }

        func updateHeight() {
            guard let textView else { return }
            guard let textContainer = textView.textContainer else { return }
            textView.layoutManager?.ensureLayout(for: textContainer)
            let usedRect = textView.layoutManager?.usedRect(for: textContainer) ?? .zero
            let newHeight = max(usedRect.height + textView.textContainerInset.height * 2, minimumHeight)
            heightBinding.wrappedValue = newHeight
        }
    }
}

final class PromptNSTextView: NSTextView {
    var returnKeyHandler: ((NSEvent.ModifierFlags) -> Void)?
    var beginEditingHandler: (() -> Void)?
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

    override func paste(_ sender: Any?) {
        if let pasteboard = NSPasteboard.general.string(forType: .string) {
            pasteHandler?(pasteboard)
        }
        super.paste(sender)
    }
}
