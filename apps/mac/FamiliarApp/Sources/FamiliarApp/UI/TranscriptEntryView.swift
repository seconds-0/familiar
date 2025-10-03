import SwiftUI
import MarkdownUI

struct TranscriptEntryView: View {
    let entry: TranscriptEntry

    private var backgroundColor: Color {
        switch entry.role {
        case .assistant:
            return Color.familiarAccent.opacity(0.05)
        case .system:
            return Color.secondary.opacity(0.08)
        case .user:
            return .clear
        }
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f
    }()

    private var timeString: String {
        Self.timeFormatter.string(from: entry.timestamp)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
            Markdown(entry.text)
                .markdownTheme(.familiar)
                .textSelection(.enabled)
                .lineSpacing(2)
                .transaction { $0.animation = nil } // Avoid jitter while streaming

            HStack {
                Spacer()
                Text(timeString)
                    .font(.familiarCaption)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true) // Time is read via label
            }
        }
        .padding(FamiliarSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: FamiliarRadius.control)
                .fill(backgroundColor)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        let rolePrefix: String
        switch entry.role {
        case .user: rolePrefix = "You said"
        case .assistant: rolePrefix = "Familiar said"
        case .system: rolePrefix = "System message"
        }
        return "\(rolePrefix) \(entry.text) at \(timeString)"
    }
}

