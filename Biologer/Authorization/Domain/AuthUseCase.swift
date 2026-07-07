import Foundation

final class AuthUseCase {
    private let loginUseCase: LoginUserUseCase
    private let registerUseCase: RegisterUserUseCase

    init(
        loginUseCase: LoginUserUseCase,
        registerUseCase: RegisterUserUseCase
    ) {
        self.loginUseCase = loginUseCase
        self.registerUseCase = registerUseCase
    }

    func login(email: String, username: String, password: String) async throws -> Void {
        try await loginUseCase.login(email: email, username: username, password: password)
    }

    func createUser(user: RegisterUser) async throws -> RegisterUserResponse {
        try await registerUseCase.createUser(user: user)
    }
}
