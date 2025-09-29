import AppKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: SettingsViewModel

    init(appState: AppState) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(appState: appState))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            authenticationSection
            workspaceSection

            if let statusMessage = viewModel.statusMessage {
                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundStyle(viewModel.statusColor)
            }

            HStack {
                Button("Test Connection", action: viewModel.testConnection)
                    .disabled(viewModel.isTesting)
                Spacer()
                Button("Save", action: viewModel.save)
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isSaving)
            }

            Spacer()
        }
        .padding(24)
        .frame(width: 520, height: 360)
        .task { await viewModel.loadSettings() }
        .onChange(of: viewModel.selectedAuthMode) { _ in
            guard !viewModel.isApplyingAuthMode else { return }
            viewModel.handleAuthModeChange()
        }
        .alert("Sign out of Claude Code?", isPresented: $viewModel.isLogoutConfirmationPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                viewModel.signOutClaude()
            }
        } message: {
            Text("Signing out here also logs you out of Claude Code in the terminal.")
        }
    }

    private var authenticationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Authentication")
                .font(.headline)

            Picker("Authentication", selection: $viewModel.selectedAuthMode) {
                ForEach(SettingsViewModel.AuthMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Group {
                switch viewModel.selectedAuthMode {
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
            apiKey: $viewModel.apiKey,
            isVisible: $viewModel.isApiKeyVisible,
            onPaste: viewModel.pasteFromClipboard,
            onVisibilityToggle: viewModel.toggleApiKeyVisibility
        )
    }

    private var claudeLoginSection: some View {
        ClaudeLoginSection(
            hasSession: $viewModel.hasClaudeSession,
            account: $viewModel.claudeAccount,
            isLoading: .constant(
                viewModel.isLoggingIn || viewModel.isLoggingOut || viewModel.isRefreshingAuth
            ),
            onSignIn: viewModel.signInClaude,
            onSignOut: { viewModel.isLogoutConfirmationPresented = true },
            onRefresh: { Task { await viewModel.refreshClaudeStatus(manual: true) } }
        )
    }

    private var workspaceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Workspace")
                .font(.headline)
            HStack(spacing: 8) {
                TextField("/path/to/workspace", text: $viewModel.workspacePath)
                    .textFieldStyle(.roundedBorder)
                Button("Browse…") {
                    if let path = viewModel.selectWorkspace() {
                        viewModel.workspacePath = path
                    }
                }
            }
        }
    }
}