import Foundation

struct SidecarEvent {
    enum EventType: String {
        case assistantText = "assistant_text"
        case toolUse = "tool_use"
        case toolResult = "tool_result"
        case permissionRequest = "permission_request"
        case permissionResolution = "permission_resolution"
        case result = "result"
        case system = "system"
        case error = "error"
    }

    let type: EventType
    let raw: [String: Any]

    init?(rawString: String) {
        guard
            let data = rawString.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let typeValue = json["type"] as? String,
            let eventType = EventType(rawValue: typeValue)
        else {
            return nil
        }
        self.type = eventType
        self.raw = json
    }

    var text: String? { raw["text"] as? String }
    var message: String? { raw["message"] as? String }
    var requestId: String? { raw["requestId"] as? String }
    var toolName: String? { raw["toolName"] as? String }
    var toolInput: [String: Any]? { raw["input"] as? [String: Any] }
    var decision: String? { raw["decision"] as? String }
    var path: String? { raw["path"] as? String }
    var canonicalPath: String? { raw["canonicalPath"] as? String }
    var snippet: String? { raw["snippet"] as? String }
    var content: String? { raw["content"] as? String }
    var diff: String? { raw["diff"] as? String }
    var isError: Bool { (raw["isError"] as? Bool) ?? false }
    var toolUseId: String? { raw["toolUseId"] as? String }
    var usage: [String: Any]? { raw["usage"] as? [String: Any] }
    var cost: [String: Any]? { raw["cost"] as? [String: Any] }
}
