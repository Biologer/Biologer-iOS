import Foundation

final class AuthUseCase {
    let loginUseCase: LoginUserUseCase
    let registerUseCase: RegisterUserUseCase
    private let environmentStorage: EnvironmentStorage

    init(
        loginUseCase: LoginUserUseCase,
        registerUseCase: RegisterUserUseCase,
        environmentStorage: EnvironmentStorage
    ) {
        self.loginUseCase = loginUseCase
        self.registerUseCase = registerUseCase
        self.environmentStorage = environmentStorage
    }

    func login(email: String, username: String, password: String) async throws -> Void {
        try await loginUseCase.login(email: email, username: username, password: password)
    }

    func createUser(user: RegistrationDraft) async throws -> Void {
        try await registerUseCase.createUser(user: user)
    }

    func selectEnvironment(_ environment: Environment) {
        environmentStorage.saveEnvironment(env: environment)
    }
}
