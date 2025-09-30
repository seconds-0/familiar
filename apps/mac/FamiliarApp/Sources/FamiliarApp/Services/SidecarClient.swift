import Foundation

actor SidecarClient {
    static let shared = SidecarClient()

    private let baseURL = URL(string: "http://127.0.0.1:8765")!
    private let jsonDecoder = JSONDecoder()

    func stream(prompt: String, sessionId: String = "default") -> AsyncThrowingStream<SidecarEvent, Error> {
        var request = URLRequest(url: baseURL.appendingPathComponent("query"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        let payload: [String: Any] = [
            "prompt": prompt,
            "session_id": sessionId
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        return AsyncThrowingStream { continuation in
            var eventTask: EventSourceTask?
            eventTask = EventSourceTask(request: request) { chunk in
                guard let event = SidecarEvent(rawString: chunk) else { return }
                continuation.yield(event)
            } completion: { error in
                if let error {
                    continuation.finish(throwing: error)
                } else {
                    continuation.finish()
                }
            }
            eventTask?.resume()

            let terminationTask = eventTask
            continuation.onTermination = { _ in
                terminationTask?.cancel()
            }
        }
    }

    func approve(requestId: String, decision: String, remember: Bool = false) async throws {
        var payload: [String: Any] = [
            "request_id": requestId,
            "decision": decision
        ]
        if remember {
            payload["remember"] = true
        }
        _ = try await sendJSON(path: "approve", method: "POST", payload: payload) as [String: Any]
    }

    func updateSettings(apiKey: String?, workspace: String?, authMode: String?) async throws -> SidecarSettings {
        var payload: [String: Any] = [:]
        if let apiKey {
            payload["anthropic_api_key"] = apiKey
        }
        if let workspace {
            payload["workspace"] = workspace
        }
        if let authMode {
            payload["auth_mode"] = authMode
        }
        return try await sendDecodable(path: "settings", method: "POST", payload: payload)
    }

    func fetchSettings() async throws -> SidecarSettings {
        return try await sendDecodable(path: "settings", method: "GET", payload: nil)
    }

    func healthCheck() async throws {
        _ = try await sendJSON(path: "health", method: "GET", payload: nil) as [String: Any]
    }

    func startClaudeLogin() async throws -> ClaudeAuthState {
        return try await sendDecodable(path: "auth/claude/login", method: "POST", payload: [:])
    }

    func logoutClaude() async throws -> ClaudeAuthState {
        return try await sendDecodable(path: "auth/claude/logout", method: "POST", payload: [:])
    }

    func fetchClaudeStatus() async throws -> ClaudeAuthState {
        return try await sendDecodable(path: "auth/claude/status", method: "GET", payload: nil)
    }

    func fetchZeroStateSuggestions() async throws -> [String] {
        struct Response: Decodable {
            let suggestions: [String]
        }
        let response: Response = try await sendDecodable(path: "zero-state/suggestions", method: "POST", payload: [:])
        return response.suggestions
    }

    // MARK: - Helpers

    private func sendJSON(path: String, method: String, payload: [String: Any]?) async throws -> [String: Any] {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let payload {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200..<300).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw SidecarClientError.http(status: http.statusCode, message: message)
        }

        if data.isEmpty {
            return [:]
        }

        let json = try JSONSerialization.jsonObject(with: data, options: [])
        return json as? [String: Any] ?? [:]
    }

    private func sendDecodable<T: Decodable>(path: String, method: String, payload: [String: Any]?) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let payload {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200..<300).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw SidecarClientError.http(status: http.statusCode, message: message)
        }
        return try jsonDecoder.decode(T.self, from: data)
    }
}

enum SidecarClientError: Error, LocalizedError {
    case http(status: Int, message: String)

    var errorDescription: String? {
        switch self {
        case let .http(status, message):
            return "Sidecar error (\(status)): \(message)"
        }
    }
}
