import Foundation
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.familiar.app", category: "FamiliarViewModel")

@MainActor
final class FamiliarViewModel: ObservableObject {
    @Published var prompt: String = ""
    @Published var transcript: String = ""
    @Published var toolSummary: ToolSummary?
    @Published var errorMessage: String?
    @Published var isStreaming: Bool = false {
        didSet {
            if isStreaming != oldValue {
                if isStreaming {
                    AgentActivityCenter.shared.beginActivity(.streaming)
                } else {
                    AgentActivityCenter.shared.endActivity(.streaming)
                }
            }
            if !isStreaming {
                stopLoadingMessages()
            }
        }
    }
    @Published var permissionRequest: PermissionRequest?
    @Published var isProcessingPermission: Bool = false {
        didSet {
            if isProcessingPermission != oldValue {
                if isProcessingPermission {
                    AgentActivityCenter.shared.beginActivity(.permission)
                } else {
                    AgentActivityCenter.shared.endActivity(.permission)
                }
            }
        }
    }
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

    // Typing effect (env toggle: FAMILIAR_TYPING_EFFECT)
    private let typingEffectEnabled: Bool = {
        let env = ProcessInfo.processInfo.environment["FAMILIAR_TYPING_EFFECT"]?.lowercased()
        guard let env else { return true } // default ON
        if ["0", "false", "no", "off"].contains(env) { return false }
        if ["1", "true", "yes", "on"].contains(env) { return true }
        return true
    }()
    private var revealTask: Task<Void, Never>?
    private var revealBuffer: String = ""

    // Session inactivity management
    private(set) var lastActivityAt: Date = Date()
    private let inactivityTimeout: TimeInterval = 30 * 60 // 30 minutes

    struct SessionSnapshot {
        let transcript: String
        let toolSummary: ToolSummary?
        let usageTotals: UsageTotals
        let lastUsage: UsageTotals?
    }
    private var previousSession: SessionSnapshot?

    // UX: dynamic, LLM-generated resume label (fallback to static)
    private(set) var resumeSuggestionTitle: String? = nil

    init() {
        // Load any persisted previous session on startup
        if let stored = SessionStore.shared.load() {
            previousSession = stored
        }
    }

    func submit() {
        let text = prompt
        prompt = ""  // Clear immediately before submission
        submitInternal(text)
    }

    func submitPrompt(_ text: String) {
        submitInternal(text)
    }

    /// Internal submission handler that bypasses the prompt field
    private func submitInternal(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
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

        // Reset typing effect state
        stopRevealLoop()
        revealBuffer = ""
        if typingEffectEnabled {
            startRevealLoop()
        }

        markActivity()
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
        }
    }

    func cancelStreaming() {
        streamTask?.cancel()
        streamTask = nil
        isStreaming = false
        stopLoadingMessages()
        flushRevealBuffer()
        stopRevealLoop()
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
        markActivity()
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
        markActivity()
        if promptPreview != nil {
            promptPreview = nil
        }
    }

    func fetchZeroStateSuggestions() async -> [String] {
        // Fetch normal zero-state suggestions
        async let baseFetch = ZeroStateCache.shared.get()

        // Optionally fetch a context-aware resume label
        let snapshot = previousSession
        async let resumeFetch: String? = { () -> String? in
            guard let snapshot = snapshot else { return nil }
            let preview = snapshot.transcript.suffix(600)
            do {
                let title = try await client.fetchResumeSuggestion(
                    transcriptPreview: String(preview),
                    path: snapshot.toolSummary?.path,
                    project: nil
                )
                return title
            } catch {
                return "Keep working on what we were doing before"
            }
        }()

        var suggestions = await baseFetch
        if let resume = await resumeFetch {
            resumeSuggestionTitle = resume
            if suggestions.first != resume {
                suggestions.insert(resume, at: 0)
            }
            if suggestions.count > 4 { suggestions = Array(suggestions.prefix(4)) }
        }
        return suggestions
    }

    func handleSuggestionTap(_ suggestion: String) {
        if suggestion == resumeSuggestionTitle {
            resumePreviousSession()
        } else {
            submitPrompt(suggestion)
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
            if typingEffectEnabled {
                revealBuffer.append(text)
            } else {
                transcript.append(text)
            }
        }
        markActivity()
    }

    private func handleToolResult(_ event: SidecarEvent) {
        toolSummary = ToolSummary.from(event: event)
        markActivity()
    }

    private func handlePermissionRequest(_ event: SidecarEvent) {
        permissionRequest = PermissionRequest.from(event: event)
        isProcessingPermission = false
        markActivity()
    }

    private func handlePermissionResolution(_ event: SidecarEvent) {
        isProcessingPermission = false
        permissionRequest = nil
        if event.decision == "deny" {
            errorMessage = "Got it — I won’t run that."
            isStreaming = false
        }
        markActivity()
    }

    private func handleResult(_ event: SidecarEvent) {
        if let totals = UsageTotals(usageDict: event.usage, costDict: event.cost) {
            usageTotals = usageTotals.adding(totals)
            lastUsage = totals
        }
        // If typing effect is enabled, let the reveal loop drain remaining text
        if !typingEffectEnabled {
            flushRevealBuffer()
            stopRevealLoop()
        }
        isStreaming = false
        markActivity()
    }

    private func handleError(_ event: SidecarEvent) {
        errorMessage = event.message ?? "Unknown error"
        if !typingEffectEnabled {
            flushRevealBuffer()
            stopRevealLoop()
        }
        isStreaming = false
        markActivity()
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

    // MARK: - Typing Effect (Typewriter)

    private func startRevealLoop() {
        guard revealTask == nil else { return }
        revealTask = Task { @MainActor [weak self] in
            let tickNs: UInt64 = 15_000_000 // 15ms
            while !(Task.isCancelled) {
                try? await Task.sleep(nanoseconds: tickNs)
                guard let self else { break }
                let backlog = self.revealBuffer.count
                if backlog == 0 {
                    if !self.isStreaming { break }
                    continue
                }
                // Adaptive chunking: catch up if backlog grows
                let chunk: Int
                if backlog > 1000 {
                    chunk = min(150, backlog)
                } else if backlog > 400 {
                    chunk = min(40, backlog)
                } else if backlog > 120 {
                    chunk = min(12, backlog)
                } else {
                    chunk = min(5, backlog) // ~333 cps
                }
                let prefix = String(self.revealBuffer.prefix(chunk))
                self.revealBuffer.removeFirst(prefix.count)
                self.transcript.append(prefix)
            }
        }
    }

    private func stopRevealLoop() {
        revealTask?.cancel()
        revealTask = nil
    }

    private func flushRevealBuffer() {
        if !revealBuffer.isEmpty {
            transcript.append(revealBuffer)
            revealBuffer.removeAll(keepingCapacity: false)
        }
    }

    var usageTotalsDisplay: UsageTotals? {
        usageTotals.hasData ? usageTotals : nil
    }

    var lastUsageDisplay: UsageTotals? {
        lastUsage
    }

    // MARK: - Inactivity + Session Management

    func evaluateInactivityReset() {
        guard !transcript.isEmpty else { return }
        let elapsed = Date().timeIntervalSince(lastActivityAt)
        if elapsed >= inactivityTimeout {
            archiveCurrentSession()
            resetToZeroState()
        }
    }

    private func archiveCurrentSession() {
        let snapshot = SessionSnapshot(
            transcript: transcript,
            toolSummary: toolSummary,
            usageTotals: usageTotals,
            lastUsage: lastUsage
        )
        previousSession = snapshot
        SessionStore.shared.save(snapshot: snapshot)
    }

    private func resetToZeroState() {
        transcript = ""
        toolSummary = nil
        errorMessage = nil
        isStreaming = false
        promptPreview = nil
        // Keep usage totals; they reflect overall
    }

    private func resumePreviousSession() {
        guard let snapshot = previousSession else { return }
        transcript = snapshot.transcript
        toolSummary = snapshot.toolSummary
        usageTotals = snapshot.usageTotals
        lastUsage = snapshot.lastUsage
        previousSession = nil
        SessionStore.shared.clear()
        markActivity()
    }

    private func markActivity() {
        lastActivityAt = Date()
    }
}
