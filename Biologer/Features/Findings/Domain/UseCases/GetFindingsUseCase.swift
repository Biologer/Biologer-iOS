protocol GetFindingsUseCase {
    func execute() throws -> [FindingSummary]
}

final class DefaultGetFindingsUseCase: GetFindingsUseCase {
    private let repository: FindingsRepository

    init(repository: FindingsRepository) {
        self.repository = repository
    }

    func execute() throws -> [FindingSummary] {
        try repository.getAll()
    }
}
