import Foundation

struct AuthorizationUseCases {
    let login: LoginUserUseCase
    let registration: RegistrationUseCase
    let selectEnvironment: SelectAuthorizationEnvironmentUseCase
    let tutorial: AuthorizationTutorialUseCase

    init(
        login: LoginUserUseCase,
        registration: RegistrationUseCase,
        selectEnvironmentUseCase: SelectAuthorizationEnvironmentUseCase,
        tutorial: AuthorizationTutorialUseCase
    ) {
        self.login = login
        self.registration = registration
        selectEnvironment = selectEnvironmentUseCase
        self.tutorial = tutorial
    }
}

protocol AuthorizationTutorialUseCase {
    var shouldPresent: Bool { get }
    func markPresented()
}

final class DefaultAuthorizationTutorialUseCase: AuthorizationTutorialUseCase {
    private let repository: AuthorizationTutorialRepository

    init(repository: AuthorizationTutorialRepository) {
        self.repository = repository
    }

    var shouldPresent: Bool {
        !repository.wasPresented
    }

    func markPresented() {
        repository.markPresented()
    }
}
