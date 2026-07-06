import Foundation

final class LoggingAPIClientDecorator: APIClientProtocol {
    private let decoratee: APIClientProtocol

    init(decoratee: APIClientProtocol) {
        self.decoratee = decoratee
    }

    func send<E: APIEndpoint>(_ endpoint: E) async throws -> E.Response {
        let requestId = String(UUID().uuidString.prefix(6))

        logRequest(endpoint, requestId: requestId)

        do {
            let result = try await decoratee.send(endpoint)
            logResponse(result, requestId: requestId)
            return result
        } catch {
            logError(error, requestId: requestId)
            throw error
        }
    }
}

// MARK: - Logging

private extension LoggingAPIClientDecorator {

    func logRequest<E: APIEndpoint>(_ endpoint: E, requestId: String) {
        print("[API][\(requestId)] -> \(endpoint.method.rawValue) \(endpoint.path)")
        if !endpoint.queryItems.isEmpty {
            print("[API][\(requestId)] query: \(endpoint.queryItems)")
        }
    }

    func logResponse<T>(_ response: T, requestId: String) {
        print("[API][\(requestId)] <- \(String(describing: response))")
    }

    func logError(_ error: Error, requestId: String) {
        print("[API][\(requestId)] error: \(error.localizedDescription)")
    }
}
