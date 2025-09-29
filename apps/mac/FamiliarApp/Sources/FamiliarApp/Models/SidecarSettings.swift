import Foundation

struct SidecarSettings: Decodable {
    let hasApiKey: Bool
    let hasClaudeSession: Bool
    let workspace: String?
    let workspaceDemoFile: String?
    let alwaysAllow: [String: [String]]
    let defaultWorkspace: String?
    let authMode: String?
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
