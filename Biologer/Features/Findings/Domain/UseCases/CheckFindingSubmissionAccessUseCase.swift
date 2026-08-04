protocol CheckFindingSubmissionAccessUseCase {
    func execute() -> Bool
}

final class DefaultCheckFindingSubmissionAccessUseCase: CheckFindingSubmissionAccessUseCase {
    private let repository: FindingSubmissionAccessRepository

    init(repository: FindingSubmissionAccessRepository) {
        self.repository = repository
    }

    func execute() -> Bool {
        repository.isUserVerified()
    }
}
