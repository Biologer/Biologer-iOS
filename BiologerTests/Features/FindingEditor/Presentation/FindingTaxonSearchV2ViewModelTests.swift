import Combine
import XCTest
@testable import Biologer

@MainActor
final class FindingTaxonSearchV2ViewModelTests: XCTestCase {
    func test_queryPublishesDebouncedResults() async {
        let expected = makeTaxon(id: 1, name: "Salamandra salamandra")
        let search = FindingTaxonSearchUseCaseStub(result: .success([expected]))
        let sut = FindingTaxonSearchV2ViewModel(
            searchTaxa: search,
            onSelect: { _ in }
        )
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
        var selectedTaxon: FindingEditorTaxon?
        let sut = FindingTaxonSearchV2ViewModel(
            searchTaxa: FindingTaxonSearchUseCaseStub(result: .success([])),
            onSelect: { selectedTaxon = $0 }
        )
        sut.query = "  Unknown species  "

        sut.useCustomName()

        XCTAssertNil(selectedTaxon?.apiID)
        XCTAssertEqual(selectedTaxon?.name, "Unknown species")
    }

    func test_selectForwardsDatabaseTaxon() {
        let taxon = makeTaxon(id: 1, name: "Alcedo atthis")
        var selectedTaxon: FindingEditorTaxon?
        let sut = FindingTaxonSearchV2ViewModel(
            searchTaxa: FindingTaxonSearchUseCaseStub(result: .success([])),
            onSelect: { selectedTaxon = $0 }
        )

        sut.select(taxon)

        XCTAssertEqual(selectedTaxon, taxon)
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
