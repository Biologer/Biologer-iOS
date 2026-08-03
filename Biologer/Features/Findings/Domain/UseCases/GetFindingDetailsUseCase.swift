import Foundation

protocol GetFindingDetailsUseCase {
    func execute(id: UUID) throws -> FindingDetails
}

final class DefaultGetFindingDetailsUseCase: GetFindingDetailsUseCase {
    private let repository: FindingDetailsRepository

    init(repository: FindingDetailsRepository) {
        self.repository = repository
    }

    func execute(id: UUID) throws -> FindingDetails {
        try repository.get(id: id)
    }
}
