import SwiftUI

struct ApprovalDecision {
    let decision: String
    let remember: Bool
}

struct ApprovalSheet: View {
    let request: PermissionRequest
    let isProcessing: Bool
    let onDecision: (ApprovalDecision) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Approve \(request.toolName) tool?")
                .font(.title3)
                .bold()

            if let path = request.path, !path.isEmpty {
                Label(path, systemImage: "doc.text")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let diff = request.diff, !diff.isEmpty {
                DiffPreviewView(diff: diff)
            } else if let preview = request.preview, !preview.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Proposed content")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ScrollView(.vertical, showsIndicators: true) {
                        Text(preview)
                            .font(.system(.callout, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                            .padding(.vertical, 4)
                    }
                    .frame(minHeight: 120, idealHeight: 180, maxHeight: 280)
                    .background(Color(nsColor: .textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(nsColor: .separatorColor).opacity(0.3), lineWidth: 1)
                    )
                }
            } else {
                Text("No preview available")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            if isProcessing {
                ProgressView().progressViewStyle(.circular)
            }

            HStack {
                Button("Deny") {
                    onDecision(ApprovalDecision(decision: "deny", remember: false))
                }
                .buttonStyle(.bordered)
                .disabled(isProcessing)

                Spacer()

                if request.canonicalPath != nil {
                    Button("Always Allow") {
                        onDecision(ApprovalDecision(decision: "allow", remember: true))
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }

                Button("Allow Once") {
                    onDecision(ApprovalDecision(decision: "allow", remember: false))
                }
                .buttonStyle(.borderedProminent)
                .disabled(isProcessing)
            }
        }
        .padding(24)
        .frame(
            minWidth: 380,
            idealWidth: 420,
            maxWidth: 520
        )
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct DiffPreviewView: View {
    let diff: String

    private var lines: [String] {
        diff.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Proposed diff")
                .font(.caption)
                .foregroundStyle(.secondary)
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(lines.enumerated()), id: \.offset) { pair in
                        let line = pair.element
                        Text(line)
                            .font(.system(.callout, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 1)
                            .foregroundStyle(color(for: line))
                            .textSelection(.enabled)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(minHeight: 150, idealHeight: 220, maxHeight: 320)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.3), lineWidth: 1)
            )
        }
    }

    private func color(for line: String) -> Color {
        if line.hasPrefix("+++") || line.hasPrefix("---") {
            return .secondary
        }
        if line.hasPrefix("+") {
            return .green
        }
        if line.hasPrefix("-") {
            return .red
        }
        return .primary
    }
}
