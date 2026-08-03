import Foundation

protocol DeleteFindingsUseCase {
    func execute(ids: [UUID]) throws
}

final class DefaultDeleteFindingsUseCase: DeleteFindingsUseCase {
    private let repository: FindingsRepository

    init(repository: FindingsRepository) {
        self.repository = repository
    }

    func execute(ids: [UUID]) throws {
        try repository.delete(ids: ids)
    }
}
