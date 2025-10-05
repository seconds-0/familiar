import Foundation
import SwiftUI

enum AgentStatus: String, Equatable {
    case spawning
    case working
    case completed
    case error
}

struct AgentNode: Identifiable, Equatable {
    let id: String
    let parentId: String?
    var title: String
    var seed: String
    var status: AgentStatus
    var timestamp: Date
    var children: [AgentNode] = []
    var summary: String? = nil
}
