import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    enum SidecarStatus: String {
        case unknown
        case ready
        case offline
        case needsConfiguration

        var label: String {
            switch self {
            case .unknown: return "Checking…"
            case .ready: return "Connected"
            case .offline: return "Offline"
            case .needsConfiguration: return "Needs Setup"
            }
        }

        var systemImage: String {
            switch self {
            case .unknown: return "questionmark.circle"
            case .ready: return "checkmark.circle.fill"
            case .offline: return "exclamationmark.triangle.fill"
            case .needsConfiguration: return "gearshape.exclamationmark"
            }
        }
    }

    @Published var status: SidecarStatus = .unknown
    @Published var statusDetail: String?
    @Published var workspaceURL: URL?
    @Published var demoFileURL: URL?

    private var monitorTask: Task<Void, Never>?
    private var healthIsOK = false
    private var configurationIsOK = false

    init() {
        monitorTask = Task { await monitorSystemHealth() }
    }

    deinit {
        monitorTask?.cancel()
    }

    func refresh() {
        Task {
            await checkHealth()
            await refreshSettings()
        }
    }

    private func monitorSystemHealth() async {
        while !Task.isCancelled {
            await checkHealth()
            await refreshSettings()
            try? await Task.sleep(nanoseconds: 10 * 1_000_000_000)
        }
    }

    private func checkHealth() async {
        do {
            try await SidecarClient.shared.healthCheck()
            healthIsOK = true
        } catch {
            healthIsOK = false
            statusDetail = "Sidecar unreachable: \(error.localizedDescription)"
        }
        updateStatus()
    }

    @discardableResult
    func refreshSettings() async -> SidecarSettings? {
        do {
            let settings = try await SidecarClient.shared.fetchSettings()
            apply(settings: settings)
            return settings
        } catch {
            configurationIsOK = false
            statusDetail = "Failed to load settings: \(error.localizedDescription)"
            updateStatus()
            return nil
        }
    }

    func apply(settings: SidecarSettings) {
        workspaceURL = settings.workspaceURL
        demoFileURL = settings.demoFileURL
        configurationIsOK = settings.hasApiKey && settings.workspace != nil
        statusDetail = configurationIsOK ? "Claude configured." : "Add API key and workspace."
        updateStatus()
    }

    private func updateStatus() {
        if !healthIsOK {
            status = .offline
            return
        }

        if !configurationIsOK {
            status = .needsConfiguration
            if statusDetail == nil || statusDetail?.isEmpty == true {
                statusDetail = "Add API key and workspace."
            }
        } else {
            status = .ready
            statusDetail = "Claude configured."
        }
    }
}
