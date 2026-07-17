import Foundation

protocol RegisterUserUseCase {
    func createUser(request: RegistrationRequest) async throws(APIError) -> Void
}

final class RemoteRegisterUserUseCase: RegisterUserUseCase {
    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage
    private let tokenStorage: TokenStorage

    public init(
        client: APIClientProtocol,
        environmentStorage: EnvironmentStorage,
        tokenStorage: TokenStorage
    ) {
        self.client = client
        self.environmentStorage = environmentStorage
        self.tokenStorage = tokenStorage
    }

    func createUser(request: RegistrationRequest) async throws(APIError) -> Void {
        guard let environment = environmentStorage.getEnvironment() else {
            throw APIError(description: ErrorConstant.environmentNotSelected)
        }

        let endpoint = RegisterUserEndpoint(
            request: request,
            host: environment.host,
            clientId: Int(environment.clientId) ?? 0,
            clientSecret: environment.clientSecret
        )

        do {
            let response = try await client.send(endpoint)
            tokenStorage.saveToken(token: Token(response))
            return
        } catch let error as APIClientError {
            throw error.asAPIError()
        } catch {
            throw APIError(description: error.localizedDescription)
        }
    }
}

private extension Token {
    convenience init(_ response: RegisterUserEndpoint.Response) {
        self.init(accessToken: response.access_token, refreshToken: response.refresh_token)
    }
}
