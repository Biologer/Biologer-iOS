import Foundation

enum AuthorizationEnvironmentSelectionError: Error, Equatable {
    case persistenceFailed
}

protocol AuthorizationEnvironmentSelectionRepository {
    func selectedEnvironmentID() -> EnvironmentID?
    func save(
        _ id: EnvironmentID
    ) throws(AuthorizationEnvironmentSelectionError)
}
