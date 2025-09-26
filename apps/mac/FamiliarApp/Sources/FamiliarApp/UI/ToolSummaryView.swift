import SwiftUI
import AppKit

struct ToolSummaryView: View {
    let summary: ToolSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: summary.isError ? "xmark.octagon" : "checkmark.seal")
                    .foregroundStyle(summary.isError ? Color.red : Color.green)
                Text(summary.isError ? "Tool reported an error" : "Change applied")
                    .font(.headline)
            }

            if let path = summary.path {
                Text(path)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let snippet = summary.snippet, !snippet.isEmpty {
                ScrollView(.vertical, showsIndicators: true) {
                    Text(snippet)
                        .font(.system(.callout, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(.vertical, 4)
                }
                .frame(minHeight: 60, idealHeight: 120, maxHeight: 200)
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(nsColor: .separatorColor).opacity(0.3), lineWidth: 1)
                )
            }

            if let content = summary.content, !content.isEmpty {
                Text(content)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
    }
}
