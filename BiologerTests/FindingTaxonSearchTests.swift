import Combine
import RealmSwift
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

final class RealmFindingTaxonSearchRepositoryTests: XCTestCase {
    private var configuration: Realm.Configuration!
    private var sut: RealmFindingTaxonSearchRepository!

    override func setUp() {
        super.setUp()
        configuration = Realm.Configuration(
            inMemoryIdentifier: "RealmFindingTaxonSearchRepositoryTests.\(UUID().uuidString)"
        )
        sut = RealmFindingTaxonSearchRepository(configuration: configuration)
    }

    override func tearDown() {
        sut = nil
        configuration = nil
        super.tearDown()
    }

    func test_searchMatchesScientificAndNativeNameAndMapsTaxonMetadata() throws {
        try storeTaxon(
            id: 1,
            name: "Salamandra salamandra",
            nativeName: "Fire salamander",
            usesAtlasCodes: true,
            stageName: "Adult"
        )
        try storeTaxon(
            id: 2,
            name: "Alcedo atthis",
            nativeName: "Kingfisher"
        )

        let scientificResult = try XCTUnwrap(
            sut.search(query: "Sala", limit: 10).first
        )
        let nativeResults = try sut.search(query: "Fire", limit: 10)

        XCTAssertEqual(scientificResult.apiID, 1)
        XCTAssertTrue(scientificResult.name.contains("Salamandra salamandra"))
        XCTAssertTrue(scientificResult.usesAtlasCodes)
        XCTAssertEqual(scientificResult.developmentStages.first?.name, "Adult")
        XCTAssertEqual(nativeResults.map(\.apiID), [1])
    }

    func test_searchSortsAndLimitsResults() throws {
        try storeTaxon(id: 1, name: "Salamandra zeta", nativeName: nil)
        try storeTaxon(id: 2, name: "Salamandra alpha", nativeName: nil)
        try storeTaxon(id: 3, name: "Salamandra beta", nativeName: nil)

        let results = try sut.search(query: "Salamandra", limit: 2)

        XCTAssertEqual(results.map(\.apiID), [2, 3])
    }

    private func storeTaxon(
        id: Int,
        name: String,
        nativeName: String?,
        usesAtlasCodes: Bool = false,
        stageName: String? = nil
    ) throws {
        let realm = try Realm(configuration: configuration)
        let taxon = DBTaxon()
        taxon.id = id
        taxon.name = name
        taxon.nativName = nativeName
        taxon.isAtlasCodeExist = usesAtlasCodes
        if let stageName {
            let stage = DBTaxonStages()
            stage.id = id * 100
            stage.name = stageName
            taxon.stages.append(stage)
        }
        if let nativeName {
            let translation = DBTaxonTranslation()
            translation.id = id * 1000
            translation.taxonId = String(id)
            translation.locale = Locale.current.language.languageCode?.identifier
            translation.nativeName = nativeName
            taxon.translations.append(translation)
        }
        try realm.write { realm.add(taxon) }
    }
}

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

private func makeTaxon(id: Int, name: String) -> FindingEditorTaxon {
    FindingEditorTaxon(
        apiID: id,
        name: name,
        usesAtlasCodes: false,
        developmentStages: [],
        translations: []
    )
}
