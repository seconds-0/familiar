import SwiftUI

struct RightSidebarView: View {
    @ObservedObject private var agents = AgentsStore.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var expanded: Set<String> = []
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
            Text("Agents").font(.familiarHeading)
            ScrollView {
                VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
                    ForEach(Array(agents.roots.enumerated()), id: \.1.id) { idx, root in
                        AgentRow(node: root, depth: 0, expanded: $expanded, compact: compact, isLast: idx == agents.roots.count - 1)
                    }
                }
            }
        }
        .padding(FamiliarSpacing.xs)
    }
}

private struct AgentRow: View {
    let node: AgentNode
    let depth: Int
    @Binding var expanded: Set<String>
    var compact: Bool
    var isLast: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: FamiliarSpacing.xs) {
                if !node.children.isEmpty {
                    Button {
                        toggle()
                    } label: {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 12)
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear.frame(width: 12)
                }
                SigilView(seed: node.seed, status: node.status)
                if !compact {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(node.title).font(.caption)
                        Text(node.summary ?? haikuSummary(node)).font(.caption2).foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
            .padding(.leading, CGFloat(depth) * 10)
            .overlay(alignment: .leading) {
                if depth > 0 {
                    ConnectorLines(isLast: isLast)
                        .padding(.leading, CGFloat(depth - 1) * 10 + 6)
                }
            }

            if isExpanded {
                ForEach(Array(node.children.enumerated()), id: \.1.id) { cidx, child in
                    AgentRow(node: child, depth: depth + 1, expanded: $expanded, compact: compact, isLast: cidx == node.children.count - 1)
                }
            }
        }
    }

    private var isExpanded: Bool { expanded.contains(node.id) }
    private func toggle() { if isExpanded { expanded.remove(node.id) } else { expanded.insert(node.id) } }
    private func accessibilityDescription(_ status: AgentStatus) -> String {
        switch status { case .spawning: return "Spawning"; case .working: return "Working"; case .completed: return "Done"; case .error: return "Error" }
    }
    private func haikuSummary(_ node: AgentNode) -> String {
        let phrases = [
            "Seeking patterns in the code",
            "Tracing quiet threads of change",
            "Fitting pieces, just so",
            "Listening for compiler whispers",
            "Sweeping crumbs from the path",
            "Gently stitching diff and file",
            "Collecting clues, one by one",
            "Letting things fall into place"
        ]
        let idx = abs(node.seed.hashValue) % phrases.count
        switch node.status {
        case .spawning: return "Arriving… \(phrases[idx])"
        case .working: return phrases[idx]
        case .completed: return "Done — \(phrases[idx].lowercased())"
        case .error: return "Hmm, something went wrong"
        }
    }
}

private struct ConnectorLines: View {
    let isLast: Bool
    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.secondary.opacity(0.25))
                    .frame(width: 1, height: isLast ? h/2 : h)
                Rectangle()
                    .fill(Color.secondary.opacity(0.25))
                    .frame(width: 10, height: 1)
                    .offset(x: 0, y: h/2)
            }
        }
        .frame(width: 12)
    }
}
