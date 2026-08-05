import Foundation

protocol SelectAuthorizationEnvironmentUseCase {
    func select(_ environment: AppEnvironment)
}

final class DefaultSelectAuthorizationEnvironmentUseCase: SelectAuthorizationEnvironmentUseCase {
    private let repository: AuthorizationEnvironmentRepository

    init(repository: AuthorizationEnvironmentRepository) {
        self.repository = repository
    }

    func select(_ environment: AppEnvironment) {
        repository.save(environment)
    }
}
