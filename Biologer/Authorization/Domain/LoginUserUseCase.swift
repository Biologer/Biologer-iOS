import Foundation

protocol LoginUserUseCase {
    func login(email: String, password: String) async throws -> LoginUserResponse
}

final class RemoteLoginUserUseCase: LoginUserUseCase {
    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage

    init(
        client: APIClientProtocol,
        environmentStorage: EnvironmentStorage
    ) {
        self.client = client
        self.environmentStorage = environmentStorage
    }

    func login(email: String, password: String) async throws -> LoginUserResponse {
        guard let environment = environmentStorage.getEnvironment() else {
            throw APIError(description: ErrorConstant.environmentNotSelected)
        }

        let endpoint = LoginUserEndpoint(
            email: email,
            password: password,
            host: environment.host,
            clientId: environment.clientId,
            clientSecret: environment.clientSecret
        )

        do {
            return try await client.send(endpoint)
        } catch let error as APIClientError {
            throw error.asAPIError()
        } catch {
            throw APIError(description: error.localizedDescription)
        }
    }
}
