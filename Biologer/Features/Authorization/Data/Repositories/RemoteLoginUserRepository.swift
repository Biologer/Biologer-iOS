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
            throw AuthorizationFailure(message: "API.lb.envError".localized)
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
                token: AuthToken(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
            )
        } catch let error as APIClientError {
            throw error.asAuthorizationFailure
        } catch {
            throw AuthorizationFailure(message: error.localizedDescription)
        }
    }
}
