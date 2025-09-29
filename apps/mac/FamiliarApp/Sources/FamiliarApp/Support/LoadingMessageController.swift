import Foundation

/// Manages rotation of loading messages to provide visual feedback during operations
final class LoadingMessageController {
    private let phrases: [String]
    private var currentMessage: String?

    init(phrases: [String]) {
        self.phrases = phrases
    }

    /// Get next loading message, avoiding repetition when possible
    ///
    /// - Returns: A randomly selected message different from the current one (if possible)
    func nextMessage() -> String {
        guard !phrases.isEmpty else {
            return "Working on it…"
        }

        var candidate = phrases.randomElement() ?? "Working on it…"

        // Try to avoid repeating the same message
        if let current = currentMessage, phrases.count > 1 {
            var attempts = 0
            while candidate == current && attempts < 5 {
                candidate = phrases.randomElement() ?? candidate
                attempts += 1
            }
        }

        currentMessage = candidate
        return candidate
    }

    /// Reset the controller state
    func reset() {
        currentMessage = nil
    }
}
