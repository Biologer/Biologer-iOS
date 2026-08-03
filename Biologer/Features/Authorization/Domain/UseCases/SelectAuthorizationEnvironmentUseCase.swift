import Foundation

protocol SelectAuthorizationEnvironmentUseCase {
    func select(_ environment: Environment)
}

final class DefaultSelectAuthorizationEnvironmentUseCase: SelectAuthorizationEnvironmentUseCase {
    private let repository: AuthorizationEnvironmentRepository

    init(repository: AuthorizationEnvironmentRepository) {
        self.repository = repository
    }

    func select(_ environment: Environment) {
        repository.save(environment)
    }
}
