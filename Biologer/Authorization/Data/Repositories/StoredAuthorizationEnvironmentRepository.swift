import Foundation

final class StoredAuthorizationEnvironmentRepository: AuthorizationEnvironmentRepository {
    private let storage: EnvironmentStorage

    init(storage: EnvironmentStorage) {
        self.storage = storage
    }

    func save(_ environment: Environment) {
        storage.saveEnvironment(env: environment)
    }
}
