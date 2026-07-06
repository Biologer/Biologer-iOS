import Foundation

final class MockAPIClient: APIClientProtocol {
    typealias ResponseProvider<E: APIEndpoint> = (E) throws -> E.Response

    var error: Error?
    var delayNanoseconds: UInt64 = 0

    private var responseProviders: [ObjectIdentifier: Any] = [:]

    func register<E: APIEndpoint>(
        _ endpointType: E.Type,
        responseProvider: @escaping ResponseProvider<E>
    ) {
        responseProviders[ObjectIdentifier(endpointType)] = responseProvider
    }

    func register<E: APIEndpoint>(_ response: E.Response, for endpointType: E.Type) {
        register(endpointType) { _ in response }
    }

    func send<E: APIEndpoint>(_ endpoint: E) async throws -> E.Response {
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }

        if let error {
            throw error
        }

        guard let provider = responseProviders[ObjectIdentifier(E.self)] as? ResponseProvider<E> else {
            throw APIClientError.missingMockResponse(String(describing: E.self))
        }

        return try provider(endpoint)
    }
}
