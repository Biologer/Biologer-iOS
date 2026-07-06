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

    func login(email: String, password: String) async throws -> LoginUserResponse {
        try await loginUseCase.login(email: email, password: password)
    }

    func createUser(user: RegisterUser) async throws -> RegisterUserResponse {
        try await registerUseCase.createUser(user: user)
    }
}
