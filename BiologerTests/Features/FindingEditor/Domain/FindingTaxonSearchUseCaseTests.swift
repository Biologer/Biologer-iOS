import XCTest
@testable import Biologer

final class FindingTaxonSearchUseCaseTests: XCTestCase {
    func test_shortQueryDoesNotReachRepository() throws {
        let repository = FindingTaxonSearchRepositorySpy()
        let sut = DefaultSearchFindingTaxaUseCase(repository: repository)

        XCTAssertEqual(try sut.execute(query: " s "), [])
        XCTAssertEqual(repository.receivedQueries, [])
    }

    func test_validQueryForwardsTrimmedTextAndLimit() throws {
        let expected = [makeTaxon(id: 1, name: "Salamandra salamandra")]
        let repository = FindingTaxonSearchRepositorySpy()
        repository.result = .success(expected)
        let sut = DefaultSearchFindingTaxaUseCase(
            repository: repository,
            resultLimit: 25
        )

        let result = try sut.execute(query: "  sala  ")

        XCTAssertEqual(result, expected)
        XCTAssertEqual(repository.receivedQueries, ["sala"])
        XCTAssertEqual(repository.receivedLimits, [25])
    }

    private func makeTaxon(id: Int, name: String) -> FindingEditorTaxon {
        FindingEditorTaxon(
            apiID: id,
            name: name,
            usesAtlasCodes: false,
            developmentStages: [],
            translations: []
        )
    }
}

private final class FindingTaxonSearchRepositorySpy: FindingTaxonSearchRepository {
    var result: Result<[FindingEditorTaxon], Error> = .success([])
    private(set) var receivedQueries: [String] = []
    private(set) var receivedLimits: [Int] = []

    func search(query: String, limit: Int) throws -> [FindingEditorTaxon] {
        receivedQueries.append(query)
        receivedLimits.append(limit)
        return try result.get()
    }
}
