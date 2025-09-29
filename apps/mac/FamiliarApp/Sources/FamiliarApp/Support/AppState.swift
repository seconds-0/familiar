import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    enum SidecarStatus: String {
        case unknown
        case initializing
        case ready
        case offline
        case needsConfiguration

        var label: String {
            switch self {
            case .unknown: return "Checking…"
            case .initializing: return "Starting…"
            case .ready: return "Connected"
            case .offline: return "Offline"
            case .needsConfiguration: return "Needs Setup"
            }
        }

        var systemImage: String {
            switch self {
            case .unknown: return "questionmark.circle"
            case .initializing: return "hourglass"
            case .ready: return "checkmark.circle.fill"
            case .offline: return "exclamationmark.triangle.fill"
            case .needsConfiguration: return "gearshape.exclamationmark"
            }
        }
    }

    @Published var status: SidecarStatus = .unknown
    @Published var statusDetail: String?
    @Published var workspaceURL: URL?

    private var monitorTask: Task<Void, Never>?
    private var backendStatus: String = "unknown"
    private var configurationIsOK = false

    init(startMonitoring: Bool = true) {
        if startMonitoring {
            monitorTask = Task { await monitorSystemHealth() }
        }
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
            let health = try await SidecarClient.shared.healthCheck()
            backendStatus = health.status

            if health.status == "degraded", let missing = health.missing {
                statusDetail = "Backend degraded: missing \(missing.joined(separator: ", "))"
            } else if health.status == "initializing" {
                statusDetail = "Backend is starting up..."
            }
        } catch {
            backendStatus = "offline"
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
        let hasWorkspace = settings.workspaceURL != nil
        let hasAuth = settings.isAuthenticated

        configurationIsOK = hasWorkspace && hasAuth

        if configurationIsOK {
            if settings.isClaudeLoginMode {
                if let account = settings.connectedAccountLabel, !account.isEmpty {
                    statusDetail = "Signed in as \(account)."
                } else {
                    statusDetail = "Claude account connected."
                }
            } else {
                statusDetail = "Claude configured."
            }
        } else {
            if !hasWorkspace {
                statusDetail = "Add workspace path."
            } else if settings.isClaudeLoginMode {
                statusDetail = "Sign in to Claude.ai."
            } else {
                statusDetail = "Add API key and workspace."
            }
        }
        updateStatus()
    }

    private func updateStatus() {
        // Handle backend status first
        switch backendStatus {
        case "initializing":
            status = .initializing
            return
        case "offline":
            status = .offline
            return
        case "degraded":
            status = .offline
            return
        case "ready":
            break // Continue to check configuration
        default:
            status = .unknown
            return
        }

        // Backend is ready, check configuration
        if !configurationIsOK {
            status = .needsConfiguration
            if statusDetail == nil || statusDetail?.isEmpty == true {
                statusDetail = "Add API key and workspace."
            }
        } else {
            status = .ready
            if statusDetail == nil || statusDetail?.isEmpty == true {
                statusDetail = "Claude configured."
            }
        }
    }
}
