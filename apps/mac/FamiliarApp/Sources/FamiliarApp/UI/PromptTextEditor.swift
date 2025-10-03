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

    private let maxVisibleLines: CGFloat = 6
    private let textInsets = NSSize(width: FamiliarSpacing.sm, height: FamiliarSpacing.xs)
    private let font = NSFont.preferredFont(forTextStyle: .body)

    private var lineHeight: CGFloat { Self.lineHeight(for: font) }
    private var minimumHeight: CGFloat { lineHeight + textInsets.height * 2 }
    private var maximumHeight: CGFloat { minimumHeight + lineHeight * (maxVisibleLines - 1) }

    private var visibleHeight: CGFloat {
        Self.visibleHeight(
            forContentHeight: contentHeight,
            minimumHeight: minimumHeight,
            maximumHeight: maximumHeight
        )
    }

    private var placeholder: String {
        if let preview, !preview.isEmpty {
            return preview
        }
        return "Ask your Familiar to do something…"
    }

    var body: some View {
        let backgroundShape = RoundedRectangle(cornerRadius: FamiliarRadius.field, style: .continuous)

        return PromptTextViewRepresentable(
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
        .frame(minHeight: visibleHeight, maxHeight: visibleHeight, alignment: .top)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .animation(.familiarInteractive, value: visibleHeight)
        .background(
            backgroundShape
                .fill(Color(nsColor: .textBackgroundColor))
        )
        .overlay(alignment: .topLeading) {
            if text.isEmpty && !isEditing {
                Text(placeholder)
                    .font(.familiarBody)
                    .italic()
                    .foregroundStyle(.tertiary)
                    .padding(.top, textInsets.height)
                    .padding(.leading, textInsets.width)
                    .allowsHitTesting(false)
                    .opacity(isEditing ? 0 : 1)
                    .animation(.familiarInteractive, value: isEditing)
            }
        }
        .clipShape(backgroundShape)
        .overlay(
            backgroundShape
                .stroke(Color.familiarAccent.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
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

extension PromptTextEditor {
    static func lineHeight(for font: NSFont) -> CGFloat {
        let sample = NSAttributedString(string: "Hg", attributes: [.font: font])
        return ceil(sample.size().height)
    }

    static func visibleHeight(forContentHeight contentHeight: CGFloat, minimumHeight: CGFloat, maximumHeight: CGFloat) -> CGFloat {
        let baseHeight = max(contentHeight, minimumHeight)
        return min(baseHeight, maximumHeight)
    }
}
