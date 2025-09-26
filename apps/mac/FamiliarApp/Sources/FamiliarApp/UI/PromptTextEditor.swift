import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct PromptTextEditor: View {
    @Binding var text: String
    let preview: String?
    let onSubmit: () -> Void
    let onPaste: (String) -> Void
    let onBeginEditing: () -> Void

    @State private var measuredHeight: CGFloat = 0

    private let maxVisibleLines: CGFloat = 4
    private let textInsets = NSSize(width: 12, height: 6)
    private let font = NSFont.preferredFont(forTextStyle: .body)

    private var lineHeight: CGFloat {
        ceil(font.ascender - font.descender + font.leading)
    }

    private var minimumHeight: CGFloat {
        lineHeight + textInsets.height * 2
    }

    private var maximumHeight: CGFloat {
        minimumHeight + lineHeight * (maxVisibleLines - 1)
    }

    var body: some View {
        let clampedHeight = min(max(measuredHeight, minimumHeight), maximumHeight)

        return ZStack(alignment: .topLeading) {
            PromptTextViewRepresentable(
                text: $text,
                preview: preview,
                measuredHeight: $measuredHeight,
                minimumHeight: minimumHeight,
                font: font,
                textInsets: textInsets,
                onSubmit: onSubmit,
                onPaste: onPaste,
                onBeginEditing: onBeginEditing
            )
            .frame(height: clampedHeight)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(nsColor: .textBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.gray.opacity(0.25))
            )

            if let preview, !preview.isEmpty {
                Text(preview)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.top, textInsets.height)
                    .padding(.leading, textInsets.width)
                    .allowsHitTesting(false)
            } else if text.isEmpty {
                Text("Ask your Familiar to do something…")
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
    let preview: String?
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
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true

        let textView = PromptNSTextView()
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = true
        textView.importsGraphics = false
        textView.usesFindBar = true
        textView.textContainerInset = textInsets
        textView.textContainer?.lineFragmentPadding = 0
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.widthTracksTextView = true
        textView.font = font
        textView.textColor = .labelColor
        textView.drawsBackground = false
        textView.backgroundColor = .clear
        textView.string = text

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

        textView.delegate = context.coordinator
        context.coordinator.textView = textView
        context.coordinator.updateHeight()

        scrollView.documentView = textView
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = context.coordinator.textView else { return }

        context.coordinator.isUpdatingFromParent = true
        if textView.string != text {
            textView.string = text
        }
        context.coordinator.isUpdatingFromParent = false

        context.coordinator.updateHeight()

        if context.environment.isFocused {
            DispatchQueue.main.async {
                textView.window?.makeFirstResponder(textView)
            }
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
            let layoutManager = textView.layoutManager
            guard let textContainer = textView.textContainer else { return }
            layoutManager?.ensureLayout(for: textContainer)
            let height = layoutManager?.usedRect(for: textContainer).height ?? minimumHeight
            let newHeight = max(height + textView.textContainerInset.height * 2, minimumHeight)
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
