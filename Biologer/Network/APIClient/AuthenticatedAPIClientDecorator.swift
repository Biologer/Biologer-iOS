import Foundation

/// Adds the latest stored access token to every protected API request.
/// The token is read at send time so a refreshed token is used automatically.
final class AuthenticatedAPIClientDecorator: APIClientProtocol {
    private let decoratee: APIClientProtocol
    private let tokenStorage: TokenStorage

    init(
        decoratee: APIClientProtocol,
        tokenStorage: TokenStorage
    ) {
        self.decoratee = decoratee
        self.tokenStorage = tokenStorage
    }

    func send<E: APIEndpoint>(_ endpoint: E) async throws -> E.Response {
        guard let accessToken = tokenStorage.getToken()?.accessToken,
              !accessToken.isEmpty else {
            throw APIClientError.unauthorized(nil)
        }

        return try await decoratee.send(
            AuthenticatedAPIEndpoint(
                endpoint: endpoint,
                accessToken: accessToken
            )
        )
    }
}

private struct AuthenticatedAPIEndpoint<Base: APIEndpoint>: APIEndpoint {
    typealias Response = Base.Response

    let endpoint: Base
    let accessToken: String

    var host: String { endpoint.host }
    var path: String { endpoint.path }
    var method: APIHTTPMethod { endpoint.method }
    var queryItems: [URLQueryItem] { endpoint.queryItems }
    var body: APIRequestBody { endpoint.body }

    var headers: [String: String] {
        var headers = endpoint.headers
        headers["Authorization"] = "Bearer \(accessToken)"
        return headers
    }
}
