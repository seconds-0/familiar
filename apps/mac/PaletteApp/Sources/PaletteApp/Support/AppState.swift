import SwiftUI

@MainActor
final class AppState: ObservableObject {
    enum SidecarStatus: String {
        case unknown
        case ready
        case offline

        var label: String {
            switch self {
            case .unknown: return "Checking…"
            case .ready: return "Connected"
            case .offline: return "Offline"
            }
        }

        var systemImage: String {
            switch self {
            case .unknown: return "questionmark.circle"
            case .ready: return "checkmark.circle.fill"
            case .offline: return "exclamationmark.triangle.fill"
            }
        }
    }

    @Published var status: SidecarStatus = .unknown

    private var monitorTask: Task<Void, Never>?

    init() {
        monitorTask = Task { await monitorHealth() }
    }

    deinit {
        monitorTask?.cancel()
    }

    func refresh() {
        Task { await checkHealth() }
    }

    private func monitorHealth() async {
        while !Task.isCancelled {
            await checkHealth()
            try? await Task.sleep(nanoseconds: 10 * 1_000_000_000)
        }
    }

    private func checkHealth() async {
        do {
            try await SidecarClient.shared.healthCheck()
            status = .ready
        } catch {
            status = .offline
        }
    }
}
