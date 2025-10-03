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

        // Extract preview based on tool type
        let preview: String? = {
            // File content operations
            if let content = input["content"] as? String {
                return content
            }

            // Bash commands
            if tool.lowercased() == "bash", let command = input["command"] as? String {
                return command
            }

            // Search operations
            if tool.lowercased() == "grep" || tool.lowercased() == "glob" {
                if let pattern = input["pattern"] as? String {
                    return "Pattern: \(pattern)"
                }
            }

            // Fallback: show first available string parameter
            for (key, value) in input {
                if let stringValue = value as? String, !stringValue.isEmpty {
                    return "\(key): \(stringValue)"
                }
            }

            return nil
        }()

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
