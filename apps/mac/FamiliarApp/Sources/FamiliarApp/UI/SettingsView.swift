import AppKit
import SwiftUI

struct SettingsView: View {
    private let keychainKey = "anthropic_api_key"

    @EnvironmentObject private var appState: AppState
    @State private var apiKey: String = ""
    @AppStorage("steelThreadWorkspacePath") private var workspacePath: String = ""
    @State private var statusMessage: String?
    @State private var statusColor: Color = .secondary
    @State private var isSaving = false
    @State private var isTesting = false
    @State private var isApiKeyVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Claude Code Credentials")
                    .font(.headline)
                HStack(spacing: 8) {
                    Group {
                        if isApiKeyVisible {
                            TextField("Anthropic API Key", text: $apiKey)
                        } else {
                            SecureField("Anthropic API Key", text: $apiKey)
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    Button {
                        isApiKeyVisible.toggle()
                    } label: {
                        Image(systemName: isApiKeyVisible ? "eye.slash" : "eye")
                    }
                    .buttonStyle(.borderless)
                    .help(isApiKeyVisible ? "Hide API key" : "Show API key")
                    Button {
                        if let clipboard = NSPasteboard.general.string(forType: .string) {
                            apiKey = clipboard.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    } label: {
                        Image(systemName: "doc.on.clipboard")
                    }
                    .buttonStyle(.borderless)
                    .help("Paste from clipboard")
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Workspace")
                    .font(.headline)
                HStack(spacing: 8) {
                    TextField("/path/to/workspace", text: $workspacePath)
                        .textFieldStyle(.roundedBorder)
                    Button("Browse…", action: selectWorkspace)
                }
            }

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
        .frame(width: 480, height: 320)
        .task { await loadSettings() }
    }

    @MainActor
    private func loadSettings() async {
        if let storedKey = (try? Keychain.load(key: keychainKey)) ?? nil {
            apiKey = storedKey
        }
        do {
            var statusOverridden = false
            var settings = try await SidecarClient.shared.fetchSettings()
            if let workspace = settings.workspace {
                workspacePath = workspace
            } else {
                let fallback = settings.defaultWorkspace ?? FileManager.default.homeDirectoryForCurrentUser.path
                workspacePath = fallback
                do {
                    settings = try await SidecarClient.shared.updateSettings(
                        apiKey: nil,
                        workspace: fallback
                    )
                } catch {
                    statusMessage = "Failed to apply default workspace: \(error.localizedDescription)"
                    statusColor = .red
                    statusOverridden = true
                }
            }
            if !statusOverridden {
                if settings.hasApiKey {
                    statusMessage = "API key configured in sidecar."
                    statusColor = .green
                } else {
                    statusMessage = "API key missing. Add one to enable Claude Code."
                    statusColor = .orange
                }
            }
            appState.apply(settings: settings)
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
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedWorkspace = workspacePath.trimmingCharacters(in: .whitespacesAndNewlines)

        isSaving = true
        Task { @MainActor in
            defer { isSaving = false }
            do {
                if trimmedKey.isEmpty {
                    try Keychain.delete(key: keychainKey)
                } else {
                    try Keychain.save(key: keychainKey, value: trimmedKey)
                }

                let settings = try await SidecarClient.shared.updateSettings(
                    apiKey: trimmedKey,
                    workspace: trimmedWorkspace
                )

                if settings.hasApiKey {
                    statusMessage = "Settings saved. Claude Code is ready."
                    statusColor = .green
                } else {
                    statusMessage = "API key still missing."
                    statusColor = .orange
                }
                if let workspace = settings.workspace {
                    workspacePath = workspace
                }
                appState.apply(settings: settings)
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
}
