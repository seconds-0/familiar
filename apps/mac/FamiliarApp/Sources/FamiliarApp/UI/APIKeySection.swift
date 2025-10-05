import AppKit
import SwiftUI

/// Authentication section for Anthropic API key entry
///
/// Provides secure/visible text field for API key entry with clipboard paste support.
struct APIKeySection: View {
    @Binding var apiKey: String
    @Binding var isVisible: Bool
    let onPaste: () -> Void
    let onVisibilityToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
            Text("Provide an Anthropic API key if you prefer manual authentication.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if apiKey.isEmpty {
                VStack(spacing: FamiliarSpacing.xs) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(.secondary)
                    Text("No API key configured")
                        .font(.headline)
                    Text("Enter your Anthropic API key to get started")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Get an API Key") {
                        NSWorkspace.shared.open(URL(string: "https://console.anthropic.com")!)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, FamiliarSpacing.sm)
            }

            HStack(spacing: FamiliarSpacing.xs) {
                keyTextField
                    .textFieldStyle(.roundedBorder)

                Button(action: onVisibilityToggle) {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                }
                .buttonStyle(.borderless)
                .help(isVisible ? "Hide API key" : "Show API key")

                Button(action: onPaste) {
                    Image(systemName: "doc.on.clipboard")
                }
                .buttonStyle(.borderless)
                .help("Paste from clipboard")
            }
        }
    }

    @ViewBuilder
    private var keyTextField: some View {
        if isVisible {
            TextField("Anthropic API Key", text: $apiKey)
        } else {
            SecureField("Anthropic API Key", text: $apiKey)
        }
    }
}

#if DEBUG
#Preview("Empty") {
    APIKeySection(
        apiKey: .constant(""),
        isVisible: .constant(false),
        onPaste: {},
        onVisibilityToggle: {}
    )
    .padding()
    .frame(width: 400)
}

#Preview("With Key (Hidden)") {
    APIKeySection(
        apiKey: .constant("sk-ant-api03-..."),
        isVisible: .constant(false),
        onPaste: {},
        onVisibilityToggle: {}
    )
    .padding()
    .frame(width: 400)
}

#Preview("With Key (Visible)") {
    APIKeySection(
        apiKey: .constant("sk-ant-api03-abcdefghijklmnopqrstuvwxyz"),
        isVisible: .constant(true),
        onPaste: {},
        onVisibilityToggle: {}
    )
    .padding()
    .frame(width: 400)
}
#endif
