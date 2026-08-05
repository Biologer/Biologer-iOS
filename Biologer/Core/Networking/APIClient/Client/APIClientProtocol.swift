import Foundation

public protocol APIClientProtocol {
    func send<E: APIEndpoint>(_ endpoint: E) async throws -> E.Response
}
