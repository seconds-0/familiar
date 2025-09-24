import Foundation

final class EventSourceTask: NSObject, URLSessionDataDelegate, URLSessionTaskDelegate {
    private let completion: (Error?) -> Void
    private let handler: (String) -> Void
    private let request: URLRequest

    private var task: URLSessionDataTask?
    private var session: URLSession?
    private var buffer = Data()

    init(request: URLRequest, handler: @escaping (String) -> Void, completion: @escaping (Error?) -> Void) {
        self.request = request
        self.handler = handler
        self.completion = completion
    }

    func resume() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        task = session?.dataTask(with: request)
        task?.resume()
    }

    func cancel() {
        task?.cancel()
        session?.invalidateAndCancel()
        session = nil
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
        let delimiter = Data("\n\n".utf8)
        while let range = buffer.range(of: delimiter) {
            let chunk = buffer.subdata(in: buffer.startIndex..<range.lowerBound)
            buffer.removeSubrange(buffer.startIndex..<range.upperBound)
            guard let payload = String(data: chunk, encoding: .utf8) else { continue }
            let lines = payload.split(separator: "\n")
            var dataString = ""
            for line in lines where line.hasPrefix("data:") {
                let value = line.dropFirst(5).trimmingCharacters(in: .whitespaces)
                dataString.append(value)
            }
            if !dataString.isEmpty {
                handler(dataString)
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        completion(error)
        cancel()
    }
}
