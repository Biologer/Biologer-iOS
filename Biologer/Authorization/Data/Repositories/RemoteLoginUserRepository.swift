import Foundation

final class RemoteLoginUserRepository: LoginUserRepository {
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

    func login(email: String, password: String) async throws(AuthorizationFailure) {
        guard let environment = environmentStorage.getEnvironment() else {
            throw AuthorizationFailure(message: ErrorConstant.environmentNotSelected)
        }

        let endpoint = LoginUserEndpoint(
            email: email,
            password: password,
            host: environment.host,
            clientId: environment.clientId,
            clientSecret: environment.clientSecret
        )

        do {
            let response = try await client.send(endpoint)
            tokenStorage.saveToken(
                token: Token(
                    accessToken: response.access_token,
                    refreshToken: response.refresh_token
                )
            )
        } catch let error as APIClientError {
            throw error.asAPIError().asAuthorizationFailure
        } catch {
            throw AuthorizationFailure(message: error.localizedDescription)
        }
    }
}
