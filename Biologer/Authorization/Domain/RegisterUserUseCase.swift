import Foundation

protocol RegisterUserUseCase {
    func createUser(user: RegisterUser) async throws -> RegisterUserResponse
}

final class RemoteRegisterUserUseCase: RegisterUserUseCase {
    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage

    public init(
        client: APIClientProtocol,
        environmentStorage: EnvironmentStorage
    ) {
        self.client = client
        self.environmentStorage = environmentStorage
    }

    func createUser(user: RegisterUser) async throws -> RegisterUserResponse {
        guard let environment = environmentStorage.getEnvironment() else {
            throw APIError(description: ErrorConstant.environmentNotSelected)
        }

        let endpoint = RegisterUserEndpoint(
            user: user,
            host: environment.host,
            clientId: Int(environment.clientId) ?? 0,
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
