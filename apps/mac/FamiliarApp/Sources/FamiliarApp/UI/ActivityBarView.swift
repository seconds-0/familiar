import SwiftUI

struct ActivityBarView: View {
    enum Stage: Hashable { case planning, tooling, replying }
    let active: Stage?
    let toolName: String?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: FamiliarSpacing.xs) {
            stageCapsule(title: "Plan", stage: .planning)
            stageCapsule(title: toolTitle, stage: .tooling)
            stageCapsule(title: "Reply", stage: .replying)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    private var toolTitle: String {
        if let toolName, !toolName.isEmpty { return toolName }
        return "Tools"
    }

    private var accessibilityDescription: String {
        guard let active else { return "Activity stages: Plan, Tools, Reply" }
        switch active {
        case .planning:
            return "Currently planning. Stages: Plan, Tools, Reply"
        case .tooling:
            return "Currently using \(toolTitle). Stages: Plan, \(toolTitle), Reply"
        case .replying:
            return "Currently replying. Stages: Plan, Tools, Reply"
        }
    }

    private func stageCapsule(title: String, stage: Stage) -> some View {
        let isActive = active == stage
        return Text(title)
            .font(.familiarCaption)
            .lineLimit(1)
            .padding(.horizontal, FamiliarSpacing.xs)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(isActive ? Color.familiarAccent.opacity(0.20) : Color.familiarSurfaceElevated.opacity(0.8))
            )
            .overlay(
                Capsule()
                    .stroke(isActive ? Color.familiarAccent.opacity(0.6) : Color(nsColor: .separatorColor).opacity(0.25), lineWidth: 1)
            )
            .foregroundStyle(isActive ? Color.familiarTextPrimary : .secondary)
            .opacity(isActive ? 1.0 : 0.9)
            .if(!reduceMotion && isActive) { view in
                view.shadow(color: Color.familiarAccent.opacity(0.25), radius: 6, x: 0, y: 0)
            }
    }
}

private extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}

