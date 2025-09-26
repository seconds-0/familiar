import Foundation
import SwiftUI

struct UsageTotals: Equatable {
    var inputTokens: Int = 0
    var outputTokens: Int = 0
    var cost: Double = 0
    var currency: String = "USD"

    var totalTokens: Int { inputTokens + outputTokens }

    var hasData: Bool {
        totalTokens > 0 || cost > 0
    }

    func adding(_ other: UsageTotals) -> UsageTotals {
        UsageTotals(
            inputTokens: inputTokens + other.inputTokens,
            outputTokens: outputTokens + other.outputTokens,
            cost: cost + other.cost,
            currency: currency
        )
    }

    init() {}

    init(inputTokens: Int, outputTokens: Int, cost: Double, currency: String) {
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.cost = cost
        self.currency = currency
    }

    init?(usageDict: [String: Any]?, costDict: [String: Any]?) {
        guard let usageDict else { return nil }
        let input = UsageTotals.parseInt(usageDict["inputTokens"]) ?? 0
        let output = UsageTotals.parseInt(usageDict["outputTokens"]) ?? 0
        if input == 0, output == 0, costDict == nil {
            return nil
        }
        let totalCost = UsageTotals.parseDouble(costDict?["total"]) ?? 0
        let currencyValue = (costDict?["currency"] as? String) ?? "USD"
        inputTokens = input
        outputTokens = output
        cost = totalCost
        currency = currencyValue
    }

    private static func parseInt(_ value: Any?) -> Int? {
        switch value {
        case let intValue as Int:
            return intValue
        case let doubleValue as Double:
            return Int(doubleValue)
        case let number as NSNumber:
            return number.intValue
        default:
            return nil
        }
    }

    private static func parseDouble(_ value: Any?) -> Double? {
        switch value {
        case let doubleValue as Double:
            return doubleValue
        case let intValue as Int:
            return Double(intValue)
        case let number as NSNumber:
            return number.doubleValue
        default:
            return nil
        }
    }
}

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
    private let loadingPhrases: [String] = [
        "Tracing the magical ley lines…",
        "Consulting the grimoire of code…",
        "Listening for compiler whispers…",
        "Surveying the workspace map…",
        "Recruiting helper sprites…",
        "Sharpening the spell quill…",
        "Puzzling through the arcane diagrams…"
    ]

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

        streamTask = Task {
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
        Task { [weak self] in
            do {
                try await self?.client.approve(requestId: request.id, decision: decision, remember: remember)
            } catch {
                self?.errorMessage = error.localizedDescription
                self?.isProcessingPermission = false
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
                errorMessage = "Permission denied. Claude could not run the requested action."
                isStreaming = false
            }
        case .result:
            if let totals = UsageTotals(usageDict: event.usage, costDict: event.cost) {
                usageTotals = usageTotals.adding(totals)
                lastUsage = totals
            }
            isStreaming = false
        case .error:
            errorMessage = event.message ?? "Unknown error"
            isStreaming = false
        default:
            break
        }
    }

    private func startLoadingMessages() {
        loadingTask?.cancel()
        loadingMessage = nextLoadingMessage()
        loadingTask = Task { [weak self] in
            while !(Task.isCancelled) {
                try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    loadingMessage = nextLoadingMessage()
                }
            }
        }
    }

    private func stopLoadingMessages() {
        loadingTask?.cancel()
        loadingTask = nil
        loadingMessage = nil
    }

    private func nextLoadingMessage() -> String {
        guard !loadingPhrases.isEmpty else {
            return "Working on it…"
        }
        var candidate = loadingPhrases.randomElement() ?? "Working on it…"
        if let current = loadingMessage, loadingPhrases.count > 1 {
            var attempts = 0
            while candidate == current && attempts < 5 {
                candidate = loadingPhrases.randomElement() ?? candidate
                attempts += 1
            }
        }
        return candidate
    }

    var usageTotalsDisplay: UsageTotals? {
        usageTotals.hasData ? usageTotals : nil
    }

    var lastUsageDisplay: UsageTotals? {
        lastUsage
    }
}
