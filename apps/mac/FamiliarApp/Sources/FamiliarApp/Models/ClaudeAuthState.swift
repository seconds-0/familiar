import Foundation

struct ClaudeAuthState: Decodable {
    let active: Bool
    let account: String?
    let message: String?
    let loginURL: URL?
    let pending: Bool?

    enum CodingKeys: String, CodingKey {
        case active
        case account
        case message
        case loginURL = "loginUrl"
        case pending
    }

    var isAuthenticated: Bool { active }
    var isPending: Bool { pending ?? false }
}
