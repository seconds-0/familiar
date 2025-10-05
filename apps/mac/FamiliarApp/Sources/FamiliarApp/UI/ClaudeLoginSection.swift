import SwiftUI

/// Authentication section for Claude.ai login flow
///
/// Displays sign in/out controls, refresh button, and current authentication status.
/// Handles the Claude.ai browser-based authentication workflow.
struct ClaudeLoginSection: View {
    @Binding var hasSession: Bool
    @Binding var account: String?
    @Binding var isLoading: Bool
    @Binding var loginState: ClaudeLoginState
    let onSignIn: () -> Void
    let onSignOut: () -> Void
    let onRefresh: () -> Void

    @State private var checkmarkScale: CGFloat = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
            Text("Sign in with your Claude.ai account to use Claude Code without managing API keys.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Security indicator when about to open browser
            if case let .waitingForUser(url) = loginState, let host = URLComponents(url: url, resolvingAgainstBaseURL: false)?.host {
                HStack(spacing: 6) {
                    Image(systemName: "lock.shield")
                        .foregroundStyle(.green)
                    Text("Redirecting to \(host)…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: FamiliarSpacing.sm) {
                // Primary action reflects state
                Button(primaryLabel) {
                    switch loginState {
                    case .notAuthenticated, .error:
                        onSignIn()
                    case .waitingForUser:
                        // No-op; user completes in browser
                        break
                    case .initiating, .verifying:
                        // No-op; pending
                        break
                    case .authenticated:
                        onSignOut()
                    }
                }
                .disabled(isLoading || isBusy)

                Button("Refresh Status", action: onRefresh)
                    .disabled(isLoading)

                if showsSpinner {
                    ProgressView().controlSize(.small)
                }

                if case let .waitingForUser(url) = loginState {
                    Button("Copy Login URL") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(url.absoluteString, forType: .string)
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
                }
            }

            statusRow
        }
        .onChange(of: loginState) { newValue in
            if case .authenticated = newValue {
                // Success animation + haptic
                withAnimation(.familiar) {
                    checkmarkScale = 1.2
                }
                NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.familiar) { checkmarkScale = 1.0 }
                }
            }
        }
    }

    private var isBusy: Bool {
        switch loginState {
        case .initiating, .verifying: return true
        default: return false
        }
    }

    private var showsSpinner: Bool {
        switch loginState {
        case .initiating, .verifying: return true
        default: return false
        }
    }

    private var primaryLabel: String {
        switch loginState {
        case .notAuthenticated, .error:
            return "Sign In"
        case .initiating:
            return "Opening browser…"
        case .waitingForUser:
            return "Complete sign-in"
        case .verifying:
            return "Verifying…"
        case .authenticated:
            return "Signed In"
        }
    }

    @ViewBuilder
    private var statusRow: some View {
        switch loginState {
        case let .authenticated(email):
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .scaleEffect(max(checkmarkScale, 1.0))
                Text(email.map { "Signed in as \($0)" } ?? "Claude account connected.")
                    .font(.subheadline)
            }
        case .notAuthenticated:
            Text("Not signed in.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        case .initiating:
            Text("Opening your browser…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        case .waitingForUser:
            Text("Complete the sign-in in your browser.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        case .verifying:
            Text("Verifying your session…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        case let .error(message):
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                Text(message)
                    .font(.subheadline)
            }
        }
    }
}

#if DEBUG
#Preview("Signed In") {
    ClaudeLoginSection(
        hasSession: .constant(true),
        account: .constant("user@example.com"),
        isLoading: .constant(false),
        loginState: .constant(.authenticated(account: "user@example.com")),
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
        loginState: .constant(.notAuthenticated),
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
        loginState: .constant(.initiating),
        onSignIn: {},
        onSignOut: {},
        onRefresh: {}
    )
    .padding()
    .frame(width: 400)
}
#endif
