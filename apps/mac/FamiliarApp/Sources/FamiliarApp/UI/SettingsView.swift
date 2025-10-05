import AppKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SettingsViewModel
    private let autoDismissOnSave: Bool
    @State private var showWorkspaceHelp: Bool = false
    @State private var showOnboarding: Bool = false

    init(appState: AppState, autoDismissOnSave: Bool = false) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(appState: appState))
        self.autoDismissOnSave = autoDismissOnSave
    }

    var body: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.md) {
            authenticationSection
            workspaceSection
            permissionsSection
            memorySection
            costSection
            integrationsSection
            toolHistorySection

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
            if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                showOnboarding = true
            }
        }
        .onDisappear {
            viewModel.onSaved = nil
        }
        .onChange(of: viewModel.apiKey) { newValue in
            viewModel.validateApiKey(newValue)
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
        .sheet(isPresented: $showOnboarding) {
            OnboardingFlow(isPresented: $showOnboarding, settingsVM: viewModel)
        }
    }

    @State private var isMemoryExpanded: Bool = false
    private var memorySection: some View {
        DisclosureGroup(isExpanded: $isMemoryExpanded) {
            VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
                HStack {
                    Button("Refresh") { viewModel.loadMemory() }
                    Button("Save") { viewModel.saveMemory() }
                        .disabled(!viewModel.isMemoryDirty)
                    Spacer()
                }
                TextEditor(text: Binding(
                    get: { viewModel.memoryText },
                    set: { new in viewModel.memoryText = new; viewModel.isMemoryDirty = true }
                ))
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 160)
                .overlay(RoundedRectangle(cornerRadius: FamiliarRadius.control).stroke(Color.gray.opacity(0.2)))
            }
            .padding(.top, FamiliarSpacing.xs)
        } label: {
            Text("Project Memory (CLAUDE.md)")
                .font(.familiarHeading)
        }
        .onChange(of: isMemoryExpanded) { expanded in
            if expanded { viewModel.loadMemory() }
        }
    }

    private var costSection: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
            Text("Costs")
                .font(.familiarHeading)
            CostDashboardView(tracker: CostTracker.shared)
        }
    }

    private var integrationsSection: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
            IntegrationsView()
        }
    }

    @State private var isHistoryExpanded: Bool = false
    private var toolHistorySection: some View {
        DisclosureGroup(isExpanded: $isHistoryExpanded) {
            ToolHistoryView(history: ToolExecutionHistory.shared)
                .frame(minHeight: 140)
        } label: {
            Text("Tool Execution History").font(.familiarHeading)
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
        VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
            APIKeySection(
                apiKey: $viewModel.apiKey,
                isVisible: $viewModel.isApiKeyVisible,
                onPaste: viewModel.pasteFromClipboard,
                onVisibilityToggle: viewModel.toggleApiKeyVisibility
            )
            if case .invalid(let reason) = viewModel.apiKeyValidation {
                Label(reason, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
                    .font(.caption)
            }
        }
    }

    private var claudeLoginSection: some View {
        ClaudeLoginSection(
            hasSession: $viewModel.hasClaudeSession,
            account: $viewModel.claudeAccount,
            isLoading: .constant(
                viewModel.isLoggingIn || viewModel.isLoggingOut || viewModel.isRefreshingAuth
            ),
            loginState: $viewModel.loginState,
            onSignIn: viewModel.signInClaude,
            onSignOut: { viewModel.isLogoutConfirmationPresented = true },
            onRefresh: { Task { await viewModel.refreshClaudeStatus(manual: true) } }
        )
    }

    private var workspaceSection: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
            HStack(spacing: FamiliarSpacing.xs) {
                Text("Workspace")
                    .font(.familiarHeading)
                Button {
                    showWorkspaceHelp = true
                } label: {
                    Image(systemName: "questionmark.circle")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
                .popover(isPresented: $showWorkspaceHelp) {
                    VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
                        Text("What's a workspace?")
                            .font(.headline)
                        Text("The folder where Familiar can read and write files. For safety, Familiar only works within this directory.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(width: 280)
                }
            }
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
