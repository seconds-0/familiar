import Foundation

/// Rich UI state for the Claude.ai login button and helpers
enum ClaudeLoginState: Equatable {
    case notAuthenticated
    case initiating
    case waitingForUser(URL)
    case verifying
    case authenticated(account: String?)
    case error(message: String)

    var isAuthenticated: Bool {
        if case .authenticated = self { return true }
        return false
    }

    var loginURL: URL? {
        if case let .waitingForUser(url) = self { return url }
        return nil
    }
}

