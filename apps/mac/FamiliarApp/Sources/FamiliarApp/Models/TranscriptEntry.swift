import Foundation

struct TranscriptEntry: Identifiable, Equatable {
    enum Role { case user, assistant, system }

    let id: UUID
    let role: Role
    var text: String
    let timestamp: Date
    var isStreaming: Bool

    init(id: UUID = UUID(), role: Role, text: String, timestamp: Date = Date(), isStreaming: Bool = false) {
        self.id = id
        self.role = role
        self.text = text
        self.timestamp = timestamp
        self.isStreaming = isStreaming
    }
}

