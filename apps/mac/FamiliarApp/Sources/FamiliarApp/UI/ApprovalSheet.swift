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
                    ScrollView {
                        Text(preview)
                            .font(.system(.callout, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
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
        .frame(width: 420)
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
            ScrollView {
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
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 8))
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
