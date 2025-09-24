import Foundation
import SwiftUI

@MainActor
final class PaletteViewModel: ObservableObject {
    @Published var prompt: String = ""
    @Published var transcript: String = ""
    @Published var toolSummary: ToolSummary?
    @Published var errorMessage: String?
    @Published var isStreaming: Bool = false
    @Published var permissionRequest: PermissionRequest?
    @Published var isProcessingPermission: Bool = false

    private var streamTask: Task<Void, Never>?
    private let client = SidecarClient.shared

    func submit() {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        streamTask?.cancel()
        transcript = ""
        toolSummary = nil
        errorMessage = nil
        permissionRequest = nil
        isStreaming = true

        streamTask = Task {
            do {
                for try await event in client.stream(prompt: trimmed) {
                    handle(event)
                }
            } catch is CancellationError {
                // Ignore cancellation; user started a new request or closed the palette.
            } catch {
                errorMessage = error.localizedDescription
            }
            isStreaming = false
        }
    }

    func cancelStreaming() {
        streamTask?.cancel()
        streamTask = nil
        isStreaming = false
    }

    func respond(to request: PermissionRequest, decision: String) {
        guard !isProcessingPermission else { return }
        isProcessingPermission = true
        Task { [weak self] in
            do {
                try await self?.client.approve(requestId: request.id, decision: decision)
            } catch {
                self?.errorMessage = error.localizedDescription
                self?.isProcessingPermission = false
            }
        }
    }

    private func handle(_ event: SidecarEvent) {
        switch event.type {
        case .assistantText:
            if let text = event.text {
                transcript.append(text)
            }
        case .toolResult:
            toolSummary = ToolSummary.from(event: event)
        case .permissionRequest:
            permissionRequest = PermissionRequest.from(event: event)
            isProcessingPermission = false
        case .permissionResolution:
            isProcessingPermission = false
            permissionRequest = nil
            if event.decision == "deny" {
                transcript.append("\n\n[Tool invocation denied]")
            }
        case .result:
            isStreaming = false
        case .error:
            errorMessage = event.message ?? "Unknown error"
            isStreaming = false
        default:
            break
        }
    }
}
