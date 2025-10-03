import AppKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SettingsViewModel
    private let autoDismissOnSave: Bool

    init(appState: AppState, autoDismissOnSave: Bool = false) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(appState: appState))
        self.autoDismissOnSave = autoDismissOnSave
    }

    var body: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.md) {
            authenticationSection
            workspaceSection
            permissionsSection

            if let statusMessage = viewModel.statusMessage {
                Text(statusMessage)
                    .font(.familiarBody)
                    .foregroundStyle(viewModel.statusColor)
            }

            HStack {
                Button("Check if it works", action: viewModel.testConnection)
                    .disabled(viewModel.isTesting)
                Spacer()
                Button("Looks good", action: viewModel.save)
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isSaving)
            }

            Spacer()
        }
        .padding(FamiliarSpacing.md)
        .frame(width: 520, height: 360)
        .task { await viewModel.loadSettings() }
        .onAppear {
            if autoDismissOnSave {
                viewModel.onSaved = { dismiss() }
            }
        }
        .onDisappear {
            viewModel.onSaved = nil
        }
        .onChange(of: viewModel.selectedAuthMode) { _ in
            guard !viewModel.isApplyingAuthMode else { return }
            viewModel.handleAuthModeChange()
        }
        .alert("Sign out of Claude Code?", isPresented: $viewModel.isLogoutConfirmationPresented) {
            Button("Not right now", role: .cancel) {}
            Button("Yes, sign me out", role: .destructive) {
                viewModel.signOutClaude()
            }
        } message: {
            Text("This will also sign you out of Claude Code in the terminal.")
        }
    }

    private var authenticationSection: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.sm) {
            Text("Authentication")
                .font(.familiarHeading)

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
        VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
            Text("Workspace")
                .font(.familiarHeading)
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

    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
            Text("Permissions")
                .font(.familiarHeading)
            Toggle(isOn: $viewModel.bypassPermissions) {
                Text("Bypass permissions (recommended)")
            }
            .toggleStyle(.switch)
            Text("The model will check in if something looks risky.")
                .font(.familiarCaption)
                .foregroundStyle(.secondary)
        }
    }
}
