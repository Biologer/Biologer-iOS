import Foundation

final class RemoteRegisterUserRepository: RegisterUserRepository {
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

    func createUser(request: RegistrationRequest) async throws(AuthorizationFailure) {
        guard let environment = environmentStorage.getEnvironment() else {
            throw AuthorizationFailure(message: "API.lb.envError".localized)
        }

        let endpoint = RegisterUserEndpoint(
            request: request,
            host: environment.host,
            clientId: Int(environment.clientId) ?? 0,
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
