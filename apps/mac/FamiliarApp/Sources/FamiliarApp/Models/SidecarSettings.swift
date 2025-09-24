import Foundation

struct SidecarSettings: Decodable {
    let hasApiKey: Bool
    let workspace: String?
    let workspaceDemoFile: String?
    let alwaysAllow: [String: [String]]
    let defaultWorkspace: String?

    private enum CodingKeys: String, CodingKey {
        case hasApiKey
        case workspace
        case workspaceDemoFile
        case alwaysAllow
        case defaultWorkspace
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hasApiKey = try container.decode(Bool.self, forKey: .hasApiKey)
        workspace = try container.decodeIfPresent(String.self, forKey: .workspace)
        workspaceDemoFile = try container.decodeIfPresent(String.self, forKey: .workspaceDemoFile)
        alwaysAllow = try container.decodeIfPresent([String: [String]].self, forKey: .alwaysAllow) ?? [:]
        defaultWorkspace = try container.decodeIfPresent(String.self, forKey: .defaultWorkspace)
    }

    var workspaceURL: URL? {
        guard let workspace else { return nil }
        return URL(fileURLWithPath: workspace)
    }

    var demoFileURL: URL? {
        guard let workspaceDemoFile else { return nil }
        return URL(fileURLWithPath: workspaceDemoFile)
    }
}
