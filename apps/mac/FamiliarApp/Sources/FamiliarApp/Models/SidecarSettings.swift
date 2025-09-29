import Foundation

/// Settings response from the Python sidecar backend.
///
/// **Schema Contract:**
/// This model must stay synchronized with `SettingsResponse` in
/// `backend/src/palette_sidecar/models.py`.
///
/// Field names use camelCase to match JSON serialization from Python's
/// Pydantic model (which uses `by_alias=True`).
struct SidecarSettings: Decodable {
    /// Whether an Anthropic API key is configured
    let hasApiKey: Bool

    /// Whether a Claude.ai session is active
    let hasClaudeSession: Bool

    /// Current workspace directory path
    let workspace: String?

    /// Path to the demo file in the workspace (if it exists)
    let workspaceDemoFile: String?

    /// Tool permissions that are always allowed (tool name -> paths)
    let alwaysAllow: [String: [String]]

    /// Default workspace path suggested by backend
    let defaultWorkspace: String?

    /// Authentication mode: "api_key" or "claude_ai"
    let authMode: String?

    /// Connected Claude.ai account email (if authenticated via claude_ai mode)
    let claudeAccountEmail: String?

    private enum CodingKeys: String, CodingKey {
        case hasApiKey
        case hasClaudeSession
        case workspace
        case workspaceDemoFile
        case alwaysAllow
        case defaultWorkspace
        case authMode
        case claudeAccountEmail
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hasApiKey = try container.decode(Bool.self, forKey: .hasApiKey)
        hasClaudeSession = try container.decodeIfPresent(Bool.self, forKey: .hasClaudeSession) ?? false
        workspace = try container.decodeIfPresent(String.self, forKey: .workspace)
        workspaceDemoFile = try container.decodeIfPresent(String.self, forKey: .workspaceDemoFile)
        alwaysAllow = try container.decodeIfPresent([String: [String]].self, forKey: .alwaysAllow) ?? [:]
        defaultWorkspace = try container.decodeIfPresent(String.self, forKey: .defaultWorkspace)
        authMode = try container.decodeIfPresent(String.self, forKey: .authMode)
        claudeAccountEmail = try container.decodeIfPresent(String.self, forKey: .claudeAccountEmail)
    }

    var workspaceURL: URL? {
        guard let workspace else { return nil }
        return URL(fileURLWithPath: workspace)
    }

    var demoFileURL: URL? {
        guard let workspaceDemoFile else { return nil }
        return URL(fileURLWithPath: workspaceDemoFile)
    }

    var isClaudeLoginMode: Bool {
        authMode == "claude_ai"
    }

    var isAuthenticated: Bool {
        if isClaudeLoginMode {
            return hasClaudeSession
        }
        return hasApiKey
    }

    var connectedAccountLabel: String? {
        if isClaudeLoginMode {
            return claudeAccountEmail
        }
        return nil
    }
}
