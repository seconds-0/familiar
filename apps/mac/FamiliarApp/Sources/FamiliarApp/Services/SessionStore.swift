import Foundation
import OSLog

final class SessionStore {
    static let shared = SessionStore()

    private let logger = Logger(subsystem: "com.familiar.app", category: "SessionStore")
    private let fileURL: URL
    private let ioQueue = DispatchQueue(label: "com.familiar.app.sessionstore")

    // Storage limits to keep file small and safe
    private let maxTranscriptChars = 10_000
    private let maxSnippetChars = 1_000
    private let maxContentChars = 2_000

    private init() {
        let fm = FileManager.default
        let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = appSupport.appendingPathComponent("FamiliarApp", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        self.fileURL = dir.appendingPathComponent("previous-session.json")
    }

    struct StoredUsageTotals: Codable {
        var inputTokens: Int
        var outputTokens: Int
        var cost: Double
        var currency: String
    }

    struct StoredToolSummary: Codable {
        var toolUseId: String
        var path: String?
        var snippet: String?
        var content: String?
        var isError: Bool
    }

    struct StoredSession: Codable {
        var transcript: String
        var toolSummary: StoredToolSummary?
        var usageTotals: StoredUsageTotals?
        var lastUsage: StoredUsageTotals?
        var savedAt: Date
    }

    func save(snapshot: FamiliarViewModel.SessionSnapshot) {
        ioQueue.async {
            let trimmedTranscript = String(snapshot.transcript.suffix(self.maxTranscriptChars))
            let summary = snapshot.toolSummary.map { ts in
                StoredToolSummary(
                    toolUseId: ts.toolUseId,
                    path: ts.path,
                    snippet: ts.snippet.map { String($0.prefix(self.maxSnippetChars)) },
                    content: ts.content.map { String($0.prefix(self.maxContentChars)) },
                    isError: ts.isError
                )
            }
            let totals = SessionStore.StoredUsageTotals(
                inputTokens: snapshot.usageTotals.inputTokens,
                outputTokens: snapshot.usageTotals.outputTokens,
                cost: snapshot.usageTotals.cost,
                currency: snapshot.usageTotals.currency
            )
            let last = snapshot.lastUsage.map {
                SessionStore.StoredUsageTotals(
                    inputTokens: $0.inputTokens,
                    outputTokens: $0.outputTokens,
                    cost: $0.cost,
                    currency: $0.currency
                )
            }
            let stored = StoredSession(
                transcript: trimmedTranscript,
                toolSummary: summary,
                usageTotals: totals,
                lastUsage: last,
                savedAt: Date()
            )
            do {
                let data = try JSONEncoder().encode(stored)
                try data.write(to: self.fileURL, options: .atomic)
                self.logger.info("Saved previous session to disk")
            } catch {
                self.logger.debug("Failed to save session: \(error.localizedDescription)")
            }
        }
    }

    func load() -> FamiliarViewModel.SessionSnapshot? {
        do {
            let data = try Data(contentsOf: fileURL)
            let stored = try JSONDecoder().decode(StoredSession.self, from: data)
            let ts = stored.toolSummary.map { s in
                ToolSummary(
                    toolUseId: s.toolUseId,
                    path: s.path,
                    snippet: s.snippet,
                    content: s.content,
                    isError: s.isError
                )
            }
            let totals = { (s: StoredUsageTotals?) -> UsageTotals in
                guard let s else { return UsageTotals() }
                return UsageTotals(
                    inputTokens: s.inputTokens,
                    outputTokens: s.outputTokens,
                    cost: s.cost,
                    currency: s.currency
                )
            }
            logger.info("Loaded previous session from disk")
            return FamiliarViewModel.SessionSnapshot(
                transcript: stored.transcript,
                toolSummary: ts,
                usageTotals: totals(stored.usageTotals),
                lastUsage: stored.lastUsage.map { totals($0) }
            )
        } catch {
            logger.debug("Failed to load session: \(error.localizedDescription)")
            return nil
        }
    }

    func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}

