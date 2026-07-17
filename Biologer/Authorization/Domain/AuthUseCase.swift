import Foundation

final class AuthUseCase {
    let loginUseCase: LoginUserUseCase
    let registrationUseCase: RegistrationUseCase
    private let environmentStorage: EnvironmentStorage

    init(
        loginUseCase: LoginUserUseCase,
        registrationUseCase: RegistrationUseCase,
        environmentStorage: EnvironmentStorage
    ) {
        self.loginUseCase = loginUseCase
        self.registrationUseCase = registrationUseCase
        self.environmentStorage = environmentStorage
    }

    func login(email: String, username: String, password: String) async throws -> Void {
        try await loginUseCase.login(email: email, username: username, password: password)
    }

    func selectEnvironment(_ environment: Environment) {
        environmentStorage.saveEnvironment(env: environment)
    }
}
