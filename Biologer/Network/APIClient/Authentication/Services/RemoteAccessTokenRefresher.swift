import Foundation

final class RemoteAccessTokenRefresher: AccessTokenRefreshing {
    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage
    private let tokenStorage: TokenStorage

    init(
        client: APIClientProtocol,
        environmentStorage: EnvironmentStorage,
        tokenStorage: TokenStorage
    ) {
        self.client = client
        self.environmentStorage = environmentStorage
        self.tokenStorage = tokenStorage
    }

    func refreshAccessToken(for session: TokenSnapshot) async throws -> String {
        guard
            let storedToken = tokenStorage.getToken(),
            !storedToken.refreshToken.isEmpty,
            let environment = environmentStorage.getEnvironment()
        else {
            throw AccessTokenRefreshError.sessionExpired(nil)
        }

        guard storedToken.accessToken == session.accessToken,
              storedToken.refreshToken == session.refreshToken else {
            throw AccessTokenRefreshError.sessionChanged
        }

        let endpoint = RefreshTokenEndpoint(
            refreshToken: storedToken.refreshToken,
            host: environment.host,
            clientId: environment.clientId,
            clientSecret: environment.clientSecret
        )

        do {
            let response = try await client.send(endpoint)
            guard !response.accessToken.isEmpty else {
                throw APIClientError.decodingFailed(
                    "The refresh response contains an empty access token."
                )
            }

            let refreshToken = response.refreshToken.flatMap { token in
                token.isEmpty ? nil : token
            } ?? storedToken.refreshToken

            // Do not resurrect a logged-out session or overwrite a token
            // belonging to a subsequent login while the request was in flight.
            guard let currentToken = tokenStorage.getToken(),
                  currentToken.accessToken == session.accessToken,
                  currentToken.refreshToken == session.refreshToken else {
                throw AccessTokenRefreshError.sessionChanged
            }

            tokenStorage.saveToken(
                token: Token(
                    accessToken: response.accessToken,
                    refreshToken: refreshToken
                )
            )
            return response.accessToken
        } catch let error as APIClientError {
            throw map(error)
        }
    }

    private func map(_ error: APIClientError) -> Error {
        switch error {
        case .badRequest(let payload), .unauthorized(let payload):
            if payload?.error == "invalid_grant" || payload?.error == "invalid_token" {
                return AccessTokenRefreshError.sessionExpired(payload)
            }
            return error
        default:
            return error
        }
    }
}
