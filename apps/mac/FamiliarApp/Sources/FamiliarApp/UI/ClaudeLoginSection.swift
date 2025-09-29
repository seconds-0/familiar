import SwiftUI

/// Authentication section for Claude.ai login flow
///
/// Displays sign in/out controls, refresh button, and current authentication status.
/// Handles the Claude.ai browser-based authentication workflow.
struct ClaudeLoginSection: View {
    @Binding var hasSession: Bool
    @Binding var account: String?
    @Binding var isLoading: Bool
    let onSignIn: () -> Void
    let onSignOut: () -> Void
    let onRefresh: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sign in with your Claude.ai account to use Claude Code without managing API keys.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                if hasSession {
                    Button("Sign Out", action: onSignOut)
                        .disabled(isLoading)
                } else {
                    Button("Sign In", action: onSignIn)
                        .disabled(isLoading)
                }

                Button("Refresh Status", action: onRefresh)
                    .disabled(isLoading)

                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                }
            }

            accountStatusText
        }
    }

    @ViewBuilder
    private var accountStatusText: some View {
        if let account = account, !account.isEmpty {
            Text("Signed in as \(account).")
                .font(.subheadline)
        } else if hasSession {
            Text("Claude account connected.")
                .font(.subheadline)
        } else {
            Text("Not signed in.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#if DEBUG
#Preview("Signed In") {
    ClaudeLoginSection(
        hasSession: .constant(true),
        account: .constant("user@example.com"),
        isLoading: .constant(false),
        onSignIn: {},
        onSignOut: {},
        onRefresh: {}
    )
    .padding()
    .frame(width: 400)
}

#Preview("Signed Out") {
    ClaudeLoginSection(
        hasSession: .constant(false),
        account: .constant(nil),
        isLoading: .constant(false),
        onSignIn: {},
        onSignOut: {},
        onRefresh: {}
    )
    .padding()
    .frame(width: 400)
}

#Preview("Loading") {
    ClaudeLoginSection(
        hasSession: .constant(false),
        account: .constant(nil),
        isLoading: .constant(true),
        onSignIn: {},
        onSignOut: {},
        onRefresh: {}
    )
    .padding()
    .frame(width: 400)
}
#endif
