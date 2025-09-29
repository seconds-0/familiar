import Foundation

struct PermissionRequest: Identifiable {
    let id: String
    let toolName: String
    let path: String?
    let canonicalPath: String?
    let preview: String?
    let diff: String?
    let rawInput: [String: Any]

    static func from(event: SidecarEvent) -> PermissionRequest? {
        guard
            event.type == .permissionRequest,
            let requestId = event.requestId,
            let tool = event.toolName
        else {
            return nil
        }

        let input = event.toolInput ?? [:]
        let path = event.path ?? input["path"] as? String
        let preview = input["content"] as? String
        return PermissionRequest(
            id: requestId,
            toolName: tool,
            path: path,
            canonicalPath: event.canonicalPath,
            preview: preview,
            diff: event.diff,
            rawInput: input
        )
    }
}

extension PermissionRequest {
    var shortSummary: String {
        if let path {
            return "\(toolName) → \(path)"
        }
        return toolName
    }
}
