import AppKit
import Foundation
import SwiftUI

/// View model managing settings business logic and state
///
/// Handles authentication flows, settings persistence, and server communication.
/// Separates business logic from UI concerns following MVVM pattern.
@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Published State

    @Published var apiKey: String = ""
    @Published var workspacePath: String = ""
    @Published var statusMessage: String?
    @Published var statusColor: Color = .secondary
    @Published var isSaving = false
    @Published var isTesting = false
    @Published var isApiKeyVisible = false
    @Published var selectedAuthMode: AuthMode = .claudeAi
    @Published var hasClaudeSession = false
    @Published var claudeAccount: String?
    @Published var isLoggingIn = false
    @Published var isLoggingOut = false
    @Published var isRefreshingAuth = false
    @Published var isApplyingAuthMode = false
    @Published var isLogoutConfirmationPresented = false

    // MARK: - Types

    enum AuthMode: String, CaseIterable, Identifiable {
        case claudeAi = "claude_ai"
        case apiKey = "api_key"

        var id: String { rawValue }

        var label: String {
            switch self {
            case .claudeAi:
                return "Claude.ai Login"
            case .apiKey:
                return "API Key"
            }
        }
    }

    // MARK: - Private Properties

    private let keychainKey = "anthropic_api_key"
    private var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    private let appState: AppState
    private let authCoordinator = AuthenticationCoordinator()

    // MARK: - Initialization

    init(appState: AppState) {
        self.appState = appState
    }

    // MARK: - Lifecycle

    func loadSettings() async {
        do {
            var statusOverridden = false
            var settings = try await SidecarClient.shared.fetchSettings()

            if settings.workspace == nil {
                let fallback = settings.defaultWorkspace ?? FileManager.default.homeDirectoryForCurrentUser.path
                workspacePath = fallback
                do {
                    settings = try await SidecarClient.shared.updateSettings(
                        apiKey: selectedAuthMode == .apiKey ? apiKey : nil,
                        workspace: fallback,
                        authMode: nil
                    )
                } catch {
                    statusMessage = "Failed to apply default workspace: \(error.localizedDescription)"
                    statusColor = .red
                    statusOverridden = true
                }
            }

            applySettings(settings, preserveStatus: statusOverridden)
        } catch {
            statusMessage = "Failed to load settings: \(error.localizedDescription)"
            statusColor = .red
        }
    }

    // MARK: - Actions

    func selectWorkspace() -> String? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            return url.path
        }
        return nil
    }

    func save() {
        let trimmedWorkspace = workspacePath.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        isSaving = true
        Task { @MainActor in
            defer { isSaving = false }
            do {
                if selectedAuthMode == .apiKey {
                    if trimmedKey.isEmpty {
                        try Keychain.delete(key: keychainKey)
                    } else {
                        try Keychain.save(key: keychainKey, value: trimmedKey)
                    }
                }

                let settings = try await SidecarClient.shared.updateSettings(
                    apiKey: selectedAuthMode == .apiKey ? trimmedKey : nil,
                    workspace: trimmedWorkspace,
                    authMode: selectedAuthMode.rawValue
                )

                applySettings(settings)

                if selectedAuthMode == .apiKey {
                    if settings.hasApiKey {
                        statusMessage = "Settings saved. Claude Code is ready."
                        statusColor = .green
                    } else {
                        statusMessage = "API key still missing."
                        statusColor = .orange
                    }
                } else {
                    updateStatusForClaudeMode()
                }
            } catch {
                statusMessage = "Failed to save: \(error.localizedDescription)"
                statusColor = .red
            }
        }
    }

    func testConnection() {
        isTesting = true
        Task { @MainActor in
            defer { isTesting = false }
            do {
                try await SidecarClient.shared.healthCheck()
                statusMessage = "Sidecar reachable."
                statusColor = .green
            } catch {
                statusMessage = "Sidecar unavailable: \(error.localizedDescription)"
                statusColor = .red
            }
        }
    }

    func pasteFromClipboard() {
        if let clipboard = NSPasteboard.general.string(forType: .string) {
            apiKey = clipboard.trimmingCharacters(in: .whitespacesAndNewlines)
            updateStatusForApiMode()
        }
    }

    func toggleApiKeyVisibility() {
        let next = !isApiKeyVisible
        isApiKeyVisible = next
        if next && apiKey.isEmpty && !isRunningTests {
            if let storedKey = (try? Keychain.load(key: keychainKey)) ?? nil {
                apiKey = storedKey
                updateStatusForApiMode()
            }
        }
    }

    // MARK: - Claude.ai Authentication

    func signInClaude() {
        guard !isLoggingIn else { return }
        authCoordinator.reset()
        isLoggingIn = true
        statusMessage = "Opening browser to sign in…"
        statusColor = .secondary
        Task { @MainActor in
            defer { isLoggingIn = false }
            do {
                let auth = try await authCoordinator.startLogin()
                updateAuthState(from: auth, overrideStatus: true)
                authCoordinator.openLoginURL(from: auth)

                if auth.isPending {
                    let finalAuth = try await authCoordinator.pollForCompletion { [weak self] status in
                        self?.updateAuthState(from: status, overrideStatus: true)
                        self?.authCoordinator.openLoginURL(from: status)
                    }
                    updateAuthState(from: finalAuth, overrideStatus: true)
                }

                await reloadSettingsFromSidecar(preserveStatus: false)
            } catch {
                statusMessage = "Login failed: \(error.localizedDescription)"
                statusColor = .red
            }
        }
    }

    func signOutClaude() {
        guard !isLoggingOut else { return }
        isLoggingOut = true
        statusMessage = "Signing out…"
        statusColor = .secondary
        Task { @MainActor in
            defer { isLoggingOut = false }
            do {
                let auth = try await authCoordinator.signOut()
                updateAuthState(from: auth, overrideStatus: true)
                await reloadSettingsFromSidecar(preserveStatus: false)
            } catch {
                statusMessage = "Logout failed: \(error.localizedDescription)"
                statusColor = .red
            }
        }
    }

    func refreshClaudeStatus(manual: Bool) async {
        guard !isRefreshingAuth else { return }
        isRefreshingAuth = true
        if manual {
            statusMessage = "Checking Claude login status…"
            statusColor = .secondary
        }
        defer { isRefreshingAuth = false }
        do {
            let auth = try await authCoordinator.refreshStatus()
            updateAuthState(from: auth, overrideStatus: manual)
            authCoordinator.openLoginURL(from: auth)
            await reloadSettingsFromSidecar(preserveStatus: !manual)
        } catch {
            statusMessage = "Failed to refresh Claude status: \(error.localizedDescription)"
            statusColor = .red
        }
    }

    func handleAuthModeChange() {
        switch selectedAuthMode {
        case .claudeAi:
            updateStatusForClaudeMode()
            Task { await refreshClaudeStatus(manual: false) }
        case .apiKey:
            updateStatusForApiMode()
        }
    }

    // MARK: - Private Methods

    private func applySettings(
        _ settings: SidecarSettings,
        preserveStatus: Bool = false
    ) {
        if let workspace = settings.workspace {
            workspacePath = workspace
        }

        let newMode = defaultAuthMode(for: settings)
        if selectedAuthMode != newMode {
            isApplyingAuthMode = true
            selectedAuthMode = newMode
            isApplyingAuthMode = false
        }

        hasClaudeSession = settings.hasClaudeSession
        claudeAccount = settings.connectedAccountLabel

        if !preserveStatus {
            switch selectedAuthMode {
            case .claudeAi:
                updateStatusMessage(mode: .claudeAi, authenticated: hasClaudeSession, account: claudeAccount)
            case .apiKey:
                updateStatusMessage(mode: .apiKey, authenticated: settings.hasApiKey, hasApiKey: settings.hasApiKey)
            }
        }

        appState.apply(settings: settings)
    }

    private func updateAuthState(from response: ClaudeAuthState, overrideStatus: Bool) {
        hasClaudeSession = response.isAuthenticated
        claudeAccount = response.account

        if overrideStatus {
            if response.isPending {
                statusMessage = response.message ?? "Complete the sign-in in your browser."
                statusColor = .secondary
            } else if response.isAuthenticated {
                updateStatusForClaudeMode(with: response)
            } else if let message = response.message, !message.isEmpty {
                statusMessage = message
                statusColor = .secondary
            } else {
                statusMessage = "Sign in to Claude.ai to enable Claude Code."
                statusColor = .orange
            }
        }
    }

    private func updateStatusMessage(
        mode: AuthMode,
        authenticated: Bool,
        account: String? = nil,
        hasApiKey: Bool = false,
        overrideMessage: String? = nil
    ) {
        if let override = overrideMessage {
            statusMessage = override
            statusColor = .secondary
            return
        }

        switch (mode, authenticated) {
        case (.claudeAi, true):
            statusMessage = account.map { "Signed in as \($0)." } ?? "Claude account connected."
            statusColor = .green
        case (.claudeAi, false):
            statusMessage = "Sign in to Claude.ai to enable Claude Code."
            statusColor = .orange
        case (.apiKey, true) where hasApiKey:
            statusMessage = "API key configured in sidecar."
            statusColor = .green
        case (.apiKey, _):
            statusMessage = apiKey.isEmpty
                ? "Enter your Anthropic API key to enable Claude Code."
                : "API key loaded. Save to apply."
            statusColor = apiKey.isEmpty ? .orange : .secondary
        }
    }

    private func updateStatusForClaudeMode(with response: ClaudeAuthState? = nil) {
        if let response {
            hasClaudeSession = response.isAuthenticated
            claudeAccount = response.account
        }
        updateStatusMessage(mode: .claudeAi, authenticated: hasClaudeSession, account: claudeAccount)
    }

    private func updateStatusForApiMode() {
        updateStatusMessage(mode: .apiKey, authenticated: !apiKey.isEmpty)
    }

    private func defaultAuthMode(for settings: SidecarSettings) -> AuthMode {
        if let raw = settings.authMode, let mode = AuthMode(rawValue: raw) {
            return mode
        }
        if settings.hasApiKey {
            return .apiKey
        }
        if settings.hasClaudeSession {
            return .claudeAi
        }
        return .claudeAi
    }

    private func reloadSettingsFromSidecar(preserveStatus: Bool = false) async {
        do {
            let settings = try await SidecarClient.shared.fetchSettings()
            applySettings(settings, preserveStatus: preserveStatus)
        } catch {
            statusMessage = "Failed to refresh settings: \(error.localizedDescription)"
            statusColor = .red
        }
    }
}