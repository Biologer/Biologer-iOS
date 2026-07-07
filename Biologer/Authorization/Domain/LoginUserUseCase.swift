import Foundation

public protocol LoginUserUseCase {
    func login(email: String, username: String, password: String) async throws(LoginError)  -> Void
}

public final class RemoteLoginUserUseCase: LoginUserUseCase {
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

    public func login(email: String, username: String,  password: String) async throws(LoginError) -> Void {
        guard let environment = environmentStorage.getEnvironment() else {
            throw LoginError.apiError(APIError(description: ErrorConstant.environmentNotSelected))
        }
        
        guard FieldsValidator.isValid(email: email) else {
            throw LoginError.invalidEmail
        }
        
        guard FieldsValidator.isEmpty(value: username) else {
            throw LoginError.invalidUsername
        }
        
        guard FieldsValidator.isEmpty(value: password) else {
            throw LoginError.invalidPassword
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
            tokenStorage.saveToken(token: Token(response))
            return
        } catch let error as APIClientError {
            throw LoginError.apiError(error.asAPIError())
        } catch {
            throw LoginError.apiError(APIError(description: error.localizedDescription))
        }
    }
}

public enum LoginError: Error {
    case invalidEmail
    case invalidPassword
    case invalidUsername
    case apiError(APIError)
}

private extension Token {
    convenience init(_ response: LoginUserEndpoint.Response) {
        self.init(accessToken: response.access_token, refreshToken: response.refresh_token)
    }
}
