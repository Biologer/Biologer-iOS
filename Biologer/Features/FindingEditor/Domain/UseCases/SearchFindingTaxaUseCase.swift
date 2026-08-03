import Foundation

protocol SearchFindingTaxaUseCase {
    func execute(query: String) throws -> [FindingEditorTaxon]
}

final class DefaultSearchFindingTaxaUseCase: SearchFindingTaxaUseCase {
    private let repository: FindingTaxonSearchRepository
    private let resultLimit: Int

    init(
        repository: FindingTaxonSearchRepository,
        resultLimit: Int = 100
    ) {
        self.repository = repository
        self.resultLimit = resultLimit
    }

    func execute(query: String) throws -> [FindingEditorTaxon] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query.count >= 2 else { return [] }
        return try repository.search(query: query, limit: resultLimit)
    }
}
