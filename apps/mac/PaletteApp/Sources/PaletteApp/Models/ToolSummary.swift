import Foundation

struct ToolSummary: Identifiable {
    let id = UUID()
    let toolUseId: String
    let path: String?
    let snippet: String?
    let content: String?
    let isError: Bool

    static func from(event: SidecarEvent) -> ToolSummary? {
        guard
            event.type == .toolResult,
            let toolUseId = event.toolUseId
        else { return nil }

        return ToolSummary(
            toolUseId: toolUseId,
            path: event.path,
            snippet: event.snippet,
            content: event.content,
            isError: event.isError
        )
    }
}
