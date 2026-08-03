import Foundation

public protocol LoginUserUseCase {
    func login(email: String, username: String, password: String) async throws(LoginError)  -> Void
}

public final class DefaultLoginUserUseCase: LoginUserUseCase {
    private let repository: LoginUserRepository

    init(repository: LoginUserRepository) {
        self.repository = repository
    }

    public func login(email: String, username: String,  password: String) async throws(LoginError) -> Void {
        guard AuthInputValidator.isNotEmpty(value: username) else {
            throw LoginError.invalidUsername
        }

        guard AuthInputValidator.isValid(email: email) else {
            throw LoginError.invalidEmail
        }

        guard AuthInputValidator.isNotEmpty(value: password) else {
            throw LoginError.invalidPassword
        }

        do {
            try await repository.login(email: email, password: password)
        } catch let failure {
            throw LoginError.authorizationFailed(failure)
        }
    }
}

public enum LoginError: Error {
    case invalidEmail
    case invalidPassword
    case invalidUsername
    case authorizationFailed(AuthorizationFailure)
}
