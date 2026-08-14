import Foundation

final class RemoteRegisterUserRepository: RegisterUserRepository {
    private let client: APIClientProtocol
    private let environmentProvider: CurrentEnvironmentProviding
    private let tokenStorage: TokenStorage

    init(
        client: APIClientProtocol,
        environmentProvider: CurrentEnvironmentProviding,
        tokenStorage: TokenStorage
    ) {
        self.client = client
        self.environmentProvider = environmentProvider
        self.tokenStorage = tokenStorage
    }

    func createUser(request: RegistrationRequest) async throws(AuthorizationFailure) {
        guard let environment = environmentProvider.currentEnvironment() else {
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
