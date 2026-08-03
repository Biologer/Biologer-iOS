import Foundation

protocol FindingsRepository {
    func getAll() throws -> [FindingSummary]
    func delete(id: UUID) throws
    func delete(ids: [UUID]) throws
    func deleteAll() throws
}

enum FindingsRepositoryError: Error, Equatable {
    case findingNotFound(UUID)
}
