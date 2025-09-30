import SwiftUI

struct ApprovalDecision {
    let decision: String
    let remember: Bool
}

struct ApprovalSheet: View {
    let request: PermissionRequest
    let isProcessing: Bool
    let onDecision: (ApprovalDecision) -> Void

    /// Generate human-friendly action description from tool name
    private var actionDescription: String {
        switch request.toolName.lowercased() {
        case "read":
            return "read this file"
        case "write":
            return "create this file"
        case "edit":
            return "edit this file"
        case "bash":
            return "run this command"
        case "grep":
            return "search these files"
        case "glob":
            return "find these files"
        default:
            return "use \(request.toolName)"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.sm) {
            Text("I can \(actionDescription) for you")
                .font(.familiarHeading)

            if let path = request.path, !path.isEmpty {
                Label(path, systemImage: "doc.text")
                    .font(.familiarCaption)
                    .foregroundStyle(.secondary)
            }

            if let diff = request.diff, !diff.isEmpty {
                DiffPreviewView(diff: diff)
            } else if let preview = request.preview, !preview.isEmpty {
                VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
                    Text("Proposed content")
                        .font(.familiarCaption)
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
                    .clipShape(RoundedRectangle(cornerRadius: FamiliarRadius.control))
                    .overlay(
                        RoundedRectangle(cornerRadius: FamiliarRadius.control)
                            .stroke(Color(nsColor: .separatorColor).opacity(0.3), lineWidth: 1)
                    )
                }
            } else {
                Text("No preview available")
                    .font(.familiarBody)
                    .foregroundStyle(.secondary)
            }

            if isProcessing {
                ProgressView().progressViewStyle(.circular)
            }

            HStack {
                Button("Not right now") {
                    onDecision(ApprovalDecision(decision: "deny", remember: false))
                }
                .buttonStyle(.bordered)
                .disabled(isProcessing)

                Spacer()

                if request.canonicalPath != nil {
                    Button("Always ok") {
                        onDecision(ApprovalDecision(decision: "allow", remember: true))
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }

                Button("Yes, do it") {
                    onDecision(ApprovalDecision(decision: "allow", remember: false))
                }
                .buttonStyle(.borderedProminent)
                .disabled(isProcessing)
            }
        }
        .padding(FamiliarSpacing.md)
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
        VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
            Text("Proposed diff")
                .font(.familiarCaption)
                .foregroundStyle(.secondary)
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(lines.enumerated()), id: \.offset) { pair in
                        let line = pair.element
                        Text(line)
                            .font(.familiarMono)
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
            .clipShape(RoundedRectangle(cornerRadius: FamiliarRadius.control))
            .overlay(
                RoundedRectangle(cornerRadius: FamiliarRadius.control)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.3), lineWidth: 1)
            )
        }
    }

    private func color(for line: String) -> Color {
        if line.hasPrefix("+++") || line.hasPrefix("---") {
            return .secondary
        }
        if line.hasPrefix("+") {
            return .familiarSuccess
        }
        if line.hasPrefix("-") {
            return .familiarError
        }
        return .primary
    }
}
