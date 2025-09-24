import Foundation

actor SidecarClient {
    static let shared = SidecarClient()

    private let baseURL = URL(string: "http://127.0.0.1:8765")!

    func stream(prompt: String) -> AsyncStream<String> {
        var request = URLRequest(url: baseURL.appendingPathComponent("query"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = ["prompt": prompt]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        return AsyncStream { continuation in
            var eventTask: EventSourceTask?
            eventTask = EventSourceTask(request: request) { chunk in
                continuation.yield(chunk)
            } completion: {
                continuation.finish()
            }
            eventTask?.resume()

            continuation.onTermination = { _ in
                eventTask?.cancel()
                eventTask = nil
            }
        }
    }

    func healthCheck() async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent("health"))
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        _ = data
    }
}
