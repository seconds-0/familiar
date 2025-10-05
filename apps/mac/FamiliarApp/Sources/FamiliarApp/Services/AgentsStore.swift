import Foundation
import SwiftUI

@MainActor
final class AgentsStore: ObservableObject {
    static let shared = AgentsStore()

    @Published private(set) var roots: [AgentNode] = []
    @Published private(set) var flatIndex: [String: AgentNode] = [:]
    private var requested: Set<String> = []

    private init() {}

    func clear() {
        roots = []
        flatIndex = [:]
    }

    func startSession(sessionId: String, prompt: String) {
        let id = "session:\(sessionId):\(UUID().uuidString)"
        let seed = "\(sessionId)|\(prompt)"
        let node = AgentNode(
            id: id,
            parentId: nil,
            title: summarize(prompt),
            seed: seed,
            status: .spawning,
            timestamp: Date()
        )
        roots.insert(node, at: 0)
        flatIndex[id] = node
        requestHaiku(for: id, title: node.title, status: .spawning, path: nil)
    }

    func markSessionWorking(sessionId: String) {
        guard let idx = roots.firstIndex(where: { $0.id.hasPrefix("session:") }) else { return }
        roots[idx].status = .working
        flatIndex[roots[idx].id] = roots[idx]
        requestHaiku(for: roots[idx].id, title: roots[idx].title, status: .working, path: nil)
    }

    func completeSession(success: Bool) {
        guard let first = roots.first else { return }
        updateNode(id: first.id) { n in n.status = success ? .completed : .error }
        requestHaiku(for: first.id, title: first.title, status: success ? .completed : .error, path: nil)
    }

    func addToolUse(parentSessionId: String?, toolUseId: String, toolName: String, input: String, path: String?) {
        let parentId = roots.first?.id
        let seed = "\(parentSessionId ?? "default")|\(path ?? "")|\(toolName)"
        let node = AgentNode(
            id: "tool:\(toolUseId)",
            parentId: parentId,
            title: toolName,
            seed: seed,
            status: .working,
            timestamp: Date()
        )
        insertChild(node, under: parentId)
        requestHaiku(for: node.id, title: node.title, status: .working, path: path)
    }

    func finishToolUse(toolUseId: String, success: Bool) {
        updateNode(id: "tool:\(toolUseId)") { n in n.status = success ? .completed : .error }
        if let node = flatIndex["tool:\(toolUseId)"] {
            requestHaiku(for: node.id, title: node.title, status: success ? .completed : .error, path: nil)
        }
    }

    func addPermissionGate(toolName: String, path: String?) {
        let parentId = roots.first?.id
        let seed = "perm|\(path ?? "")|\(toolName)"
        let node = AgentNode(
            id: "perm:\(UUID().uuidString)",
            parentId: parentId,
            title: "Permission for \(toolName)",
            seed: seed,
            status: .working,
            timestamp: Date()
        )
        insertChild(node, under: parentId)
    }

    private func insertChild(_ child: AgentNode, under parentId: String?) {
        guard let parentId else { roots.insert(child, at: 0); flatIndex[child.id] = child; return }
        if let rootIdx = roots.firstIndex(where: { $0.id == parentId }) {
            var parent = roots[rootIdx]
            parent.children.insert(child, at: 0)
            roots[rootIdx] = parent
            flatIndex[parent.id] = parent
            flatIndex[child.id] = child
        } else {
            // Insert at root if parent missing
            roots.insert(child, at: 0)
            flatIndex[child.id] = child
        }
    }

    private func updateNode(id: String, _ mutate: (inout AgentNode) -> Void) {
        if let rootIdx = roots.firstIndex(where: { $0.id == id }) {
            var node = roots[rootIdx]
            mutate(&node)
            roots[rootIdx] = node
            flatIndex[id] = node
            return
        }
        // Search recursively for children
        for i in roots.indices {
            if let updated = updateChild(in: &roots[i], id: id, mutate) {
                roots[i] = updated
                return
            }
        }
    }

    private func updateChild(in node: inout AgentNode, id: String, _ mutate: (inout AgentNode) -> Void) -> AgentNode? {
        if let idx = node.children.firstIndex(where: { $0.id == id }) {
            var child = node.children[idx]
            mutate(&child)
            node.children[idx] = child
            flatIndex[id] = child
            return node
        }
        for i in node.children.indices {
            if let updated = updateChild(in: &node.children[i], id: id, mutate) {
                node.children[i] = updated
                return node
            }
        }
        return nil
    }

    private func summarize(_ prompt: String) -> String {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= 48 { return trimmed }
        return String(trimmed.prefix(46)) + "…"
    }

    private func requestHaiku(for id: String, title: String, status: AgentStatus, path: String?) {
        guard !requested.contains(id) else { return }
        requested.insert(id)
        Task { @MainActor in
            do {
                let resp = try await SidecarClient.shared.fetchAgentHaiku(seed: id, title: title, status: status.rawValue, path: path)
                updateNode(id: id) { n in n.summary = resp.summary }
                objectWillChange.send()
            } catch {
                // Keep template fallback in UI
            }
        }
    }
}
