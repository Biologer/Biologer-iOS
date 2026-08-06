import Combine
import XCTest
@testable import Biologer

@MainActor
final class FindingTaxonSearchViewModelTests: XCTestCase {
    func test_queryPublishesDebouncedResults() async {
        let expected = makeTaxon(id: 1, name: "Salamandra salamandra")
        let search = FindingTaxonSearchUseCaseStub(result: .success([expected]))
        let sut = FindingTaxonSearchViewModel(searchTaxa: search)
        let loaded = expectation(description: "debounced search loaded")
        let observation = sut.$state.sink { state in
            if state == .results { loaded.fulfill() }
        }

        sut.query = "sala"

        await fulfillment(of: [loaded], timeout: 1)
        XCTAssertEqual(search.receivedQueries, ["sala"])
        XCTAssertEqual(sut.results, [expected])
        withExtendedLifetime(observation) {}
    }

    func test_customNameCreatesTaxonWithoutAPIID() {
        let sut = FindingTaxonSearchViewModel(
            searchTaxa: FindingTaxonSearchUseCaseStub(result: .success([]))
        )
        sut.query = "  Unknown species  "

        let selectedTaxon = sut.customTaxon()

        XCTAssertNil(selectedTaxon?.apiID)
        XCTAssertEqual(selectedTaxon?.name, "Unknown species")
    }

    func test_shortCustomNameDoesNotCreateTaxon() {
        let sut = FindingTaxonSearchViewModel(
            searchTaxa: FindingTaxonSearchUseCaseStub(result: .success([]))
        )
        sut.query = " A "

        let selectedTaxon = sut.customTaxon()

        XCTAssertNil(selectedTaxon)
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

private final class FindingTaxonSearchUseCaseStub: SearchFindingTaxaUseCase {
    var result: Result<[FindingEditorTaxon], Error>
    private(set) var receivedQueries: [String] = []

    init(result: Result<[FindingEditorTaxon], Error>) {
        self.result = result
    }

    func execute(query: String) throws -> [FindingEditorTaxon] {
        receivedQueries.append(query)
        return try result.get()
    }
}
