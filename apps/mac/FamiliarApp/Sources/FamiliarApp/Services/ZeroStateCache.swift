import Foundation
import OSLog

actor ZeroStateCache {
    static let shared = ZeroStateCache()

    private let client = SidecarClient.shared
    private var cached: [String]? = nil
    private var isFetching: Bool = false
    private let logger = Logger(subsystem: "com.familiar.app", category: "ZeroStateCache")

    /// Pre-fetch suggestions at app startup. Silent on error.
    func prewarm() async {
        if cached != nil || isFetching { return }
        isFetching = true
        defer { isFetching = false }
        do {
            let suggestions = try await client.fetchZeroStateSuggestions()
            if !suggestions.isEmpty {
                cached = suggestions
                logger.info("🔥 Pre-warm complete: \(suggestions.count) suggestions cached")
            } else {
                logger.info("🔥 Pre-warm returned empty suggestions")
            }
        } catch {
            logger.debug("Pre-warm failed: \(error.localizedDescription)")
        }
    }

    /// Returns cached suggestions or fetches if missing. Returns empty on error.
    func get() async -> [String] {
        if let cached { return cached }
        if isFetching { // lightweight wait-loop to avoid duplicate fetches
            // Spin-wait briefly; in real app we could use AsyncStream/continuation.
            try? await Task.sleep(nanoseconds: 150 * 1_000_000) // 150ms
            if let cached { return cached }
        }
        isFetching = true
        defer { isFetching = false }
        do {
            let suggestions = try await client.fetchZeroStateSuggestions()
            if !suggestions.isEmpty {
                cached = suggestions
            }
            return suggestions
        } catch {
            return []
        }
    }
}

