import RealmSwift
import XCTest
@testable import Biologer

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
