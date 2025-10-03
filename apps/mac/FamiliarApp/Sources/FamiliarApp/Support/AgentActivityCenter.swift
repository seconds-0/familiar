import Foundation
import Combine

/// Tracks lightweight, app-wide agent activity so the menu bar icon
/// can reflect when work is in progress vs idle.
@MainActor
final class AgentActivityCenter: ObservableObject {
    static let shared = AgentActivityCenter()

    enum Activity: Hashable {
        case streaming
        case permission
    }

    /// Internal counters for activity types. We keep counts to be robust
    /// to overlapping work begin/end calls.
    private var counters: [Activity: Int] = [:]

    /// Published flag that views can observe for menu bar animation/state.
    @Published private(set) var isWorking: Bool = false

    private init() {}

    func beginActivity(_ activity: Activity) {
        let current = counters[activity] ?? 0
        counters[activity] = current + 1
        updateIsWorking()
    }

    func endActivity(_ activity: Activity) {
        let current = counters[activity] ?? 0
        counters[activity] = max(0, current - 1)
        updateIsWorking()
    }

    private func updateIsWorking() {
        isWorking = counters.values.reduce(0, +) > 0
    }
}

