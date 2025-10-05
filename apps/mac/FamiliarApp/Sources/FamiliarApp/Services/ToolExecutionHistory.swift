import Foundation
import SwiftUI

final class ToolExecutionHistory: ObservableObject {
    static let shared = ToolExecutionHistory()
    @Published private(set) var executions: [Execution] = []

    struct Execution: Identifiable {
        enum Status { case running, success, error }
        let id: String
        let toolName: String
        let input: String
        var output: String = ""
        var startedAt: Date = Date()
        var endedAt: Date?
        var status: Status = .running

        var duration: Int {
            guard let end = endedAt else { return Int(Date().timeIntervalSince(startedAt) * 1000) }
            return Int(end.timeIntervalSince(startedAt) * 1000)
        }

        var statusIcon: String {
            switch status { case .running: return "clock"; case .success: return "checkmark.circle"; case .error: return "exclamationmark.triangle" }
        }
        var statusColor: Color {
            switch status { case .running: return .secondary; case .success: return .green; case .error: return .orange }
        }
        var timestamp: Date { startedAt }
        var icon: String { statusIcon }
        var statusLabel: String { status == .running ? "running" : (status == .success ? "done" : "error") }
    }

    func recordToolUse(id: String, name: String, input: String) {
        let exec = Execution(id: id, toolName: name, input: input)
        executions.insert(exec, at: 0)
        prune()
    }

    func recordToolResult(id: String, output: String, isError: Bool) {
        guard let idx = executions.firstIndex(where: { $0.id == id }) else { return }
        executions[idx].output = output
        executions[idx].endedAt = Date()
        executions[idx].status = isError ? .error : .success
    }

    private func prune() { if executions.count > 50 { executions.removeLast(executions.count - 50) } }
}

