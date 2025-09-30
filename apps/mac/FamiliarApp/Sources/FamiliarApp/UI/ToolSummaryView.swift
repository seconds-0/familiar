import SwiftUI
import AppKit

struct ToolSummaryView: View {
    let summary: ToolSummary

    var body: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
            HStack(spacing: FamiliarSpacing.xs) {
                Image(systemName: summary.isError ? "xmark.octagon" : "checkmark.seal")
                    .foregroundStyle(summary.isError ? Color.familiarError : Color.familiarSuccess)
                Text(summary.isError ? "Tool reported an error" : "Change applied")
                    .font(.familiarHeading)
            }

            if let path = summary.path {
                Text(path)
                    .font(.familiarCaption)
                    .foregroundStyle(.secondary)
            }

            if let snippet = summary.snippet, !snippet.isEmpty {
                ScrollView(.vertical, showsIndicators: true) {
                    Text(snippet)
                        .font(.familiarMono)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(.vertical, FamiliarSpacing.xs)
                }
                .frame(minHeight: 60, idealHeight: 120, maxHeight: 200)
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: FamiliarRadius.control))
                .overlay(
                    RoundedRectangle(cornerRadius: FamiliarRadius.control)
                        .stroke(Color(nsColor: .separatorColor).opacity(0.3), lineWidth: 1)
                )
            }

            if let content = summary.content, !content.isEmpty {
                Text(content)
                    .font(.familiarCaption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(FamiliarSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: FamiliarRadius.card)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
    }
}
