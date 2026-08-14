protocol AuthorizationEnvironmentSelectionUseCase {
    func selectedEnvironmentID() -> EnvironmentID?
    func select(
        _ id: EnvironmentID
    ) throws(AuthorizationEnvironmentSelectionError)
}

final class DefaultAuthorizationEnvironmentSelectionUseCase:
    AuthorizationEnvironmentSelectionUseCase {
    private let repository: AuthorizationEnvironmentSelectionRepository

    init(repository: AuthorizationEnvironmentSelectionRepository) {
        self.repository = repository
    }

    func selectedEnvironmentID() -> EnvironmentID? {
        repository.selectedEnvironmentID()
    }

    func select(
        _ id: EnvironmentID
    ) throws(AuthorizationEnvironmentSelectionError) {
        try repository.save(id)
    }
}
