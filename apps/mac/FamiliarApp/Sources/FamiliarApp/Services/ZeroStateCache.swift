import Foundation
import OSLog

actor ZeroStateCache {
    static let shared = ZeroStateCache()

    private let client = SidecarClient.shared
    private var cached: [String]? = nil
    private var fetchTask: Task<[String], Never>? = nil
    private let logger = Logger(subsystem: "com.familiar.app", category: "ZeroStateCache")

    /// Pre-fetch suggestions at app startup. Silent on error.
    func prewarm() async {
        if cached != nil || fetchTask != nil { return }

        let task = Task<[String], Never> {
            do {
                let suggestions = try await self.client.fetchZeroStateSuggestions()
                if !suggestions.isEmpty {
                    self.cached = suggestions
                    self.logger.info("🔥 Pre-warm complete: \(suggestions.count) suggestions cached")
                } else {
                    self.logger.info("🔥 Pre-warm returned empty suggestions")
                }
                return suggestions
            } catch {
                self.logger.debug("Pre-warm failed: \(error.localizedDescription)")
                return []
            }
        }

        fetchTask = task
        _ = await task.value
        fetchTask = nil
    }

    /// Returns cached suggestions or fetches if missing. Returns empty on error.
    func get() async -> [String] {
        if let cached { return cached }

        // If there's already a fetch in progress, wait for it
        if let existingTask = fetchTask {
            return await existingTask.value
        }

        // Start a new fetch
        let task = Task<[String], Never> {
            do {
                let suggestions = try await self.client.fetchZeroStateSuggestions()
                if !suggestions.isEmpty {
                    self.cached = suggestions
                }
                return suggestions
            } catch {
                return []
            }
        }

        fetchTask = task
        let result = await task.value
        fetchTask = nil
        return result
    }
}

