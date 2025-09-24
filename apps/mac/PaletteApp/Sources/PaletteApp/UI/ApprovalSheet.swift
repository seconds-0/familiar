import SwiftUI

struct ApprovalSheet: View {
    let request: PermissionRequest
    let isProcessing: Bool
    let onDecision: (String) -> Void

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

            if let preview = request.preview, !preview.isEmpty {
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
                    onDecision("deny")
                }
                .buttonStyle(.bordered)
                .disabled(isProcessing)

                Spacer()

                Button("Allow Once") {
                    onDecision("allow")
                }
                .buttonStyle(.borderedProminent)
                .disabled(isProcessing)
            }
        }
        .padding(24)
        .frame(width: 420)
    }
}
