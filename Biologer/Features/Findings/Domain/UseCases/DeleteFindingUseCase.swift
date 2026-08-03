import Foundation

protocol DeleteFindingUseCase {
    func execute(id: UUID) throws
}

final class DefaultDeleteFindingUseCase: DeleteFindingUseCase {
    private let repository: FindingsRepository

    init(repository: FindingsRepository) {
        self.repository = repository
    }

    func execute(id: UUID) throws {
        try repository.delete(id: id)
    }
}
