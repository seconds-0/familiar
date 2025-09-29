import AppKit
import Foundation

/// Coordinates Claude.ai authentication flow
///
/// Handles browser-based login, polling for completion, and URL extraction.
/// Mirrors the backend auth_coordinator.py pattern for consistency.
@MainActor
final class AuthenticationCoordinator {
    /// Error types specific to authentication flow
    enum AuthError: LocalizedError {
        case timeout
        case loginFailed(String)

        var errorDescription: String? {
            switch self {
            case .timeout:
                return "Claude login did not complete in time."
            case .loginFailed(let message):
                return "Login failed: \(message)"
            }
        }
    }

    /// State of the authentication coordinator
    @Published private(set) var isInProgress: Bool = false
    @Published private(set) var didOpenLoginURL: Bool = false

    /// Start Claude.ai login flow
    ///
    /// - Returns: Initial authentication state from server
    /// - Throws: Network or server errors
    func startLogin() async throws -> ClaudeAuthState {
        isInProgress = true
        didOpenLoginURL = false
        defer { isInProgress = false }

        return try await SidecarClient.shared.startClaudeLogin()
    }

    /// Sign out from Claude.ai
    ///
    /// - Returns: Updated authentication state after logout
    /// - Throws: Network or server errors
    func signOut() async throws -> ClaudeAuthState {
        isInProgress = true
        defer { isInProgress = false }

        return try await SidecarClient.shared.logoutClaude()
    }

    /// Refresh current authentication status
    ///
    /// - Returns: Current authentication state from server
    /// - Throws: Network or server errors
    func refreshStatus() async throws -> ClaudeAuthState {
        try await SidecarClient.shared.fetchClaudeStatus()
    }

    /// Poll for login completion with exponential backoff
    ///
    /// Polls the server until login completes or timeout is reached.
    ///
    /// - Parameters:
    ///   - maxAttempts: Maximum number of polling attempts (default: 120)
    ///   - initialDelay: Initial delay between attempts in nanoseconds (default: 1 second)
    ///   - statusHandler: Optional callback invoked with each status update
    /// - Returns: Final authentication state when login completes
    /// - Throws: AuthError.timeout if max attempts reached, or network/server errors
    func pollForCompletion(
        maxAttempts: Int = 120,
        initialDelay: UInt64 = 1_000_000_000,
        statusHandler: ((ClaudeAuthState) -> Void)? = nil
    ) async throws -> ClaudeAuthState {
        for attempt in 0..<maxAttempts {
            if attempt > 0 {
                try await Task.sleep(nanoseconds: initialDelay)
            }

            let status = try await refreshStatus()
            statusHandler?(status)

            if !status.isPending {
                return status
            }
        }

        throw AuthError.timeout
    }

    /// Open login URL in default browser
    ///
    /// Attempts to extract and open the login URL from the auth state.
    /// Handles both explicit loginURL field and URL extraction from message.
    ///
    /// - Parameter authState: Authentication state containing login URL
    /// - Returns: True if a URL was opened, false otherwise
    @discardableResult
    func openLoginURL(from authState: ClaudeAuthState) -> Bool {
        guard !didOpenLoginURL else { return false }

        if let url = authState.loginURL {
            openURL(url)
            didOpenLoginURL = true
            return true
        }

        if !authState.isAuthenticated,
           let fallbackURL = extractFirstURL(from: authState.message) {
            openURL(fallbackURL)
            didOpenLoginURL = true
            return true
        }

        return false
    }

    /// Reset coordinator state
    ///
    /// Clears flags like didOpenLoginURL for fresh authentication flow.
    func reset() {
        didOpenLoginURL = false
        isInProgress = false
    }

    // MARK: - Private Methods

    private func openURL(_ url: URL) {
        NSWorkspace.shared.open(url)
    }

    private func extractFirstURL(from text: String?) -> URL? {
        guard let text else { return nil }
        let pattern = #"https?://\S+"#
        if let range = text.range(of: pattern, options: .regularExpression) {
            let urlString = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            return URL(string: urlString)
        }
        return nil
    }
}