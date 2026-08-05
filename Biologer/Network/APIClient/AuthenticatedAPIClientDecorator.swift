import Foundation

/// Authorizes protected requests and performs one retry after a successful
/// access-token refresh. The refresh operation is provided separately so it
/// can be shared and coalesced across concurrent requests.
final class AuthenticatedAPIClientDecorator: APIClientProtocol {
    private let decoratee: APIClientProtocol
    private let tokenStorage: TokenStorage
    private let tokenRefresher: AccessTokenRefreshing
    private let onSessionExpired: @MainActor () -> Void

    init(
        decoratee: APIClientProtocol,
        tokenStorage: TokenStorage,
        tokenRefresher: AccessTokenRefreshing,
        onSessionExpired: @escaping @MainActor () -> Void = {}
    ) {
        self.decoratee = decoratee
        self.tokenStorage = tokenStorage
        self.tokenRefresher = tokenRefresher
        self.onSessionExpired = onSessionExpired
    }

    func send<E: APIEndpoint>(_ endpoint: E) async throws -> E.Response {
        guard let storedToken = tokenStorage.getToken() else {
            throw APIClientError.unauthorized(nil)
        }

        let session = TokenSnapshot(
            accessToken: storedToken.accessToken,
            refreshToken: storedToken.refreshToken
        )

        guard !storedToken.accessToken.isEmpty else {
            await invalidateSession(expectedSession: session)
            throw APIClientError.unauthorized(nil)
        }

        do {
            return try await send(
                endpoint,
                accessToken: storedToken.accessToken
            )
        } catch APIClientError.unauthorized {
            return try await refreshAndRetry(
                endpoint,
                session: session
            )
        }
    }

    private func refreshAndRetry<E: APIEndpoint>(
        _ endpoint: E,
        session: TokenSnapshot
    ) async throws -> E.Response {
        do {
            let accessToken = try await tokenRefresher.refreshAccessToken(for: session)

            // A logout/login may have happened while refresh was in flight.
            // Never replay the old request with the new session's token.
            guard tokenStorage.getToken()?.accessToken == accessToken else {
                throw AccessTokenRefreshError.sessionChanged
            }

            do {
                return try await send(endpoint, accessToken: accessToken)
            } catch APIClientError.unauthorized(let payload) {
                await invalidateSession(expectedAccessToken: accessToken)
                throw APIClientError.unauthorized(payload)
            }
        } catch AccessTokenRefreshError.sessionExpired(let payload) {
            await invalidateSession(expectedSession: session)
            throw APIClientError.unauthorized(payload)
        } catch AccessTokenRefreshError.sessionChanged {
            throw APIClientError.unauthorized(nil)
        }
    }

    private func send<E: APIEndpoint>(
        _ endpoint: E,
        accessToken: String
    ) async throws -> E.Response {
        try await decoratee.send(
            AuthenticatedAPIEndpoint(
                endpoint: endpoint,
                accessToken: accessToken
            )
        )
    }

    @MainActor
    private func invalidateSession(
        expectedSession: TokenSnapshot? = nil,
        expectedAccessToken: String? = nil) {
        guard let currentToken = tokenStorage.getToken() else { return }

        if let expectedSession,
           (currentToken.accessToken != expectedSession.accessToken ||
            currentToken.refreshToken != expectedSession.refreshToken) {
            return
        }

        if let expectedAccessToken,
           currentToken.accessToken != expectedAccessToken {
            return
        }

        tokenStorage.delete()
        onSessionExpired()
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
