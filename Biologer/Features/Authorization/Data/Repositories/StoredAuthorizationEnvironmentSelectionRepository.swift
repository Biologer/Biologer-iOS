import Foundation

final class StoredAuthorizationEnvironmentSelectionRepository:
    AuthorizationEnvironmentSelectionRepository {
    private let storage: EnvironmentSelectionStorage

    init(storage: EnvironmentSelectionStorage) {
        self.storage = storage
    }

    func selectedEnvironmentID() -> EnvironmentID? {
        storage.selectedEnvironmentID()
    }

    func save(
        _ id: EnvironmentID
    ) throws(AuthorizationEnvironmentSelectionError) {
        do {
            try storage.saveEnvironmentID(id)
        } catch {
            throw .persistenceFailed
        }
    }
}
