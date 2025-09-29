import AppKit
import SwiftUI

struct SettingsView: View {
    private let keychainKey = "anthropic_api_key"
    private var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

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

    @EnvironmentObject private var appState: AppState
    @State private var apiKey: String = ""
    @AppStorage("steelThreadWorkspacePath") private var workspacePath: String = ""
    @State private var statusMessage: String?
    @State private var statusColor: Color = .secondary
    @State private var isSaving = false
    @State private var isTesting = false
    @State private var isApiKeyVisible = false
    @State private var selectedAuthMode: AuthMode = .claudeAi
    @State private var hasClaudeSession = false
    @State private var claudeAccount: String?
    @State private var isLoggingIn = false
    @State private var isLoggingOut = false
    @State private var isRefreshingAuth = false
    @State private var isApplyingAuthMode = false
    @State private var didOpenLoginURL = false
    @State private var isLogoutConfirmationPresented = false

    private enum ClaudeLoginError: LocalizedError {
        case timeout

        var errorDescription: String? {
            switch self {
            case .timeout:
                return "Claude login did not complete in time."
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            authenticationSection
            workspaceSection

            if let statusMessage {
                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundStyle(statusColor)
            }

            HStack {
                Button("Test Connection", action: testConnection)
                    .disabled(isTesting)
                Spacer()
                Button("Save", action: save)
                    .buttonStyle(.borderedProminent)
                    .disabled(isSaving)
            }

            Spacer()
        }
        .padding(24)
        .frame(width: 520, height: 360)
        .task { await loadSettings() }
        .onChange(of: selectedAuthMode) { _ in
            guard !isApplyingAuthMode else { return }
            handleAuthModeChange()
        }
        .alert("Sign out of Claude Code?", isPresented: $isLogoutConfirmationPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                signOutClaude()
            }
        } message: {
            Text("Signing out here also logs you out of Claude Code in the terminal.")
        }
    }

    private var authenticationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Authentication")
                .font(.headline)

            Picker("Authentication", selection: $selectedAuthMode) {
                ForEach(AuthMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Group {
                switch selectedAuthMode {
                case .claudeAi:
                    claudeLoginSection
                case .apiKey:
                    apiKeySection
                }
            }
        }
    }

    private var apiKeySection: some View {
        APIKeySection(
            apiKey: $apiKey,
            isVisible: $isApiKeyVisible,
            onPaste: pasteFromClipboard,
            onVisibilityToggle: toggleApiKeyVisibility
        )
    }

    private var claudeLoginSection: some View {
        ClaudeLoginSection(
            hasSession: $hasClaudeSession,
            account: $claudeAccount,
            isLoading: .constant(isLoggingIn || isLoggingOut || isRefreshingAuth),
            onSignIn: signInClaude,
            onSignOut: { isLogoutConfirmationPresented = true },
            onRefresh: { Task { await refreshClaudeStatus(manual: true) } }
        )
    }

    private var workspaceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Workspace")
                .font(.headline)
            HStack(spacing: 8) {
                TextField("/path/to/workspace", text: $workspacePath)
                    .textFieldStyle(.roundedBorder)
                Button("Browse…", action: selectWorkspace)
            }
        }
    }

    @MainActor
    private func loadSettings() async {
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

    private func selectWorkspace() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            workspacePath = url.path
        }
    }

    private func save() {
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

    private func testConnection() {
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

    private func signInClaude() {
        guard !isLoggingIn else { return }
        didOpenLoginURL = false
        isLoggingIn = true
        statusMessage = "Opening browser to sign in…"
        statusColor = .secondary
        Task { @MainActor in
            defer { isLoggingIn = false }
            do {
                let auth = try await SidecarClient.shared.startClaudeLogin()
                updateAuthState(from: auth, overrideStatus: true)
                openLoginURLIfNeeded(from: auth)
                if auth.isPending {
                    try await pollClaudeLoginCompletion()
                } else {
                    await reloadSettingsFromSidecar(preserveStatus: false)
                }
            } catch {
                statusMessage = "Login failed: \(error.localizedDescription)"
                statusColor = .red
            }
        }
    }

    private func signOutClaude() {
        guard !isLoggingOut else { return }
        isLoggingOut = true
        statusMessage = "Signing out…"
        statusColor = .secondary
        Task { @MainActor in
            defer { isLoggingOut = false }
            do {
                let auth = try await SidecarClient.shared.logoutClaude()
                updateAuthState(from: auth, overrideStatus: true)
                await reloadSettingsFromSidecar(preserveStatus: false)
            } catch {
                statusMessage = "Logout failed: \(error.localizedDescription)"
                statusColor = .red
            }
        }
    }

    private func refreshClaudeStatus(manual: Bool) async {
        guard !isRefreshingAuth else { return }
        isRefreshingAuth = true
        if manual {
            statusMessage = "Checking Claude login status…"
            statusColor = .secondary
        }
        defer { isRefreshingAuth = false }
        do {
            let auth = try await SidecarClient.shared.fetchClaudeStatus()
            updateAuthState(from: auth, overrideStatus: manual)
            openLoginURLIfNeeded(from: auth)
            await reloadSettingsFromSidecar(preserveStatus: !manual)
        } catch {
            statusMessage = "Failed to refresh Claude status: \(error.localizedDescription)"
            statusColor = .red
        }
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

    private func handleAuthModeChange() {
        switch selectedAuthMode {
        case .claudeAi:
            updateStatusForClaudeMode()
            Task { await refreshClaudeStatus(manual: false) }
        case .apiKey:
            updateStatusForApiMode()
        }
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

    @MainActor
    private func reloadSettingsFromSidecar(preserveStatus: Bool = false) async {
        do {
            let settings = try await SidecarClient.shared.fetchSettings()
            applySettings(settings, preserveStatus: preserveStatus)
        } catch {
            statusMessage = "Failed to refresh settings: \(error.localizedDescription)"
            statusColor = .red
        }
    }

    @MainActor
    private func pollClaudeLoginCompletion(maxAttempts: Int = 120) async throws {
        for attempt in 0..<maxAttempts {
            if attempt > 0 {
                try await Task.sleep(nanoseconds: 1_000_000_000)
            }

            let status = try await SidecarClient.shared.fetchClaudeStatus()
            updateAuthState(from: status, overrideStatus: true)
            openLoginURLIfNeeded(from: status)

            if !status.isPending {
                await reloadSettingsFromSidecar(preserveStatus: false)
                return
            }
        }

        throw ClaudeLoginError.timeout
    }

    private func openLoginURLIfNeeded(from auth: ClaudeAuthState) {
        guard !didOpenLoginURL else { return }
        if let url = auth.loginURL {
            openLoginURL(url)
            didOpenLoginURL = true
            return
        }

        if !auth.isAuthenticated, let fallback = extractFirstURL(from: auth.message) {
            openLoginURL(fallback)
            didOpenLoginURL = true
        }
    }

    private func openLoginURL(_ url: URL) {
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

    // MARK: - API Key Section Helpers

    private func pasteFromClipboard() {
        if let clipboard = NSPasteboard.general.string(forType: .string) {
            apiKey = clipboard.trimmingCharacters(in: .whitespacesAndNewlines)
            updateStatusForApiMode()
        }
    }

    private func toggleApiKeyVisibility() {
        let next = !isApiKeyVisible
        isApiKeyVisible = next
        if next && apiKey.isEmpty && !isRunningTests {
            if let storedKey = (try? Keychain.load(key: keychainKey)) ?? nil {
                apiKey = storedKey
                updateStatusForApiMode()
            }
        }
    }
}
