protocol DeleteAllFindingsUseCase {
    func execute() throws
}

final class DefaultDeleteAllFindingsUseCase: DeleteAllFindingsUseCase {
    private let repository: FindingsRepository

    init(repository: FindingsRepository) {
        self.repository = repository
    }

    func execute() throws {
        try repository.deleteAll()
    }
}
