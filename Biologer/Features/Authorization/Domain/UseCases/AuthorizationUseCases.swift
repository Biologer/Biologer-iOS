import Foundation

struct AuthorizationUseCases {
    let login: LoginUserUseCase
    let registration: RegistrationUseCase
    private let selectEnvironmentUseCase: SelectAuthorizationEnvironmentUseCase

    init(
        login: LoginUserUseCase,
        registration: RegistrationUseCase,
        selectEnvironmentUseCase: SelectAuthorizationEnvironmentUseCase
    ) {
        self.login = login
        self.registration = registration
        self.selectEnvironmentUseCase = selectEnvironmentUseCase
    }

    func selectEnvironment(_ environment: AppEnvironment) {
        selectEnvironmentUseCase.select(environment)
    }
}
