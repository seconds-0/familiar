import Foundation
import SwiftUI

@MainActor
final class FamiliarViewModel: ObservableObject {
    @Published var prompt: String = ""
    @Published var transcript: String = ""
    @Published var toolSummary: ToolSummary?
    @Published var errorMessage: String?
    @Published var isStreaming: Bool = false {
        didSet {
            if !isStreaming {
                stopLoadingMessages()
            }
        }
    }
    @Published var permissionRequest: PermissionRequest?
    @Published var isProcessingPermission: Bool = false
    @Published var loadingMessage: String?
    @Published var promptPreview: String?
    @Published private(set) var usageTotals = UsageTotals()
    @Published private(set) var lastUsage: UsageTotals?

    private var streamTask: Task<Void, Never>?
    private let client = SidecarClient.shared
    private var loadingTask: Task<Void, Never>?
    private let loadingController = LoadingMessageController(phrases: [
        "Tracing the magical ley lines…",
        "Consulting the grimoire of code…",
        "Listening for compiler whispers…",
        "Surveying the workspace map…",
        "Recruiting helper sprites…",
        "Sharpening the spell quill…",
        "Puzzling through the arcane diagrams…"
    ])

    func submit() {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        streamTask?.cancel()
        transcript = ""
        toolSummary = nil
        errorMessage = nil
        permissionRequest = nil
        isStreaming = true
        lastUsage = nil
        promptPreview = nil
        startLoadingMessages()

        streamTask = Task { @MainActor in
            do {
                let stream = await client.stream(prompt: trimmed)
                for try await event in stream {
                    handle(event)
                }
            } catch is CancellationError {
                // Expected when user cancels or starts another request.
            } catch {
                errorMessage = error.localizedDescription
            }
            isStreaming = false
            stopLoadingMessages()
            prompt = ""
        }
    }

    func cancelStreaming() {
        streamTask?.cancel()
        streamTask = nil
        isStreaming = false
        stopLoadingMessages()
        promptPreview = nil
    }

    func respond(to request: PermissionRequest, decision: String, remember: Bool) {
        guard !isProcessingPermission else { return }
        isProcessingPermission = true
        Task { @MainActor [weak self] in
            defer {
                // Ensure spinner is always reset, even if resolution event is dropped
                self?.isProcessingPermission = false
            }
            do {
                try await self?.client.approve(requestId: request.id, decision: decision, remember: remember)
                // Permission resolution event will update UI state when it arrives
            } catch {
                await MainActor.run {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func handlePaste(_ value: String) {
        prompt = value
        let lines = value.split(separator: "\n", omittingEmptySubsequences: false)
        let tooManyLines = lines.count > 20
        let tooLarge = value.count > 1000
        if tooManyLines || tooLarge {
            promptPreview = "[Pasted \(lines.count) lines]"
        } else {
            promptPreview = nil
        }
    }

    func beginEditingPrompt() {
        if promptPreview != nil {
            promptPreview = nil
        }
    }

    private func handle(_ event: SidecarEvent) {
        switch event.type {
        case .assistantText:
            handleAssistantText(event)
        case .toolResult:
            handleToolResult(event)
        case .permissionRequest:
            handlePermissionRequest(event)
        case .permissionResolution:
            handlePermissionResolution(event)
        case .result:
            handleResult(event)
        case .error:
            handleError(event)
        default:
            break
        }
    }

    // MARK: - Event Handlers

    private func handleAssistantText(_ event: SidecarEvent) {
        if let text = event.text {
            transcript.append(text)
        }
    }

    private func handleToolResult(_ event: SidecarEvent) {
        toolSummary = ToolSummary.from(event: event)
    }

    private func handlePermissionRequest(_ event: SidecarEvent) {
        permissionRequest = PermissionRequest.from(event: event)
        isProcessingPermission = false
    }

    private func handlePermissionResolution(_ event: SidecarEvent) {
        isProcessingPermission = false
        permissionRequest = nil
        if event.decision == "deny" {
            errorMessage = "Permission denied. Claude could not run the requested action."
            isStreaming = false
        }
    }

    private func handleResult(_ event: SidecarEvent) {
        if let totals = UsageTotals(usageDict: event.usage, costDict: event.cost) {
            usageTotals = usageTotals.adding(totals)
            lastUsage = totals
        }
        isStreaming = false
    }

    private func handleError(_ event: SidecarEvent) {
        errorMessage = event.message ?? "Unknown error"
        isStreaming = false
    }

    // MARK: - Loading Messages

    private func startLoadingMessages() {
        loadingTask?.cancel()
        loadingMessage = loadingController.nextMessage()
        loadingTask = Task { [weak self] in
            while !(Task.isCancelled) {
                try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    loadingMessage = loadingController.nextMessage()
                }
            }
        }
    }

    private func stopLoadingMessages() {
        loadingTask?.cancel()
        loadingTask = nil
        loadingMessage = nil
        loadingController.reset()
    }

    var usageTotalsDisplay: UsageTotals? {
        usageTotals.hasData ? usageTotals : nil
    }

    var lastUsageDisplay: UsageTotals? {
        lastUsage
    }
}
