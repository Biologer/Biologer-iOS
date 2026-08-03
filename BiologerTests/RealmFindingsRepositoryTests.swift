import RealmSwift
import XCTest
@testable import Biologer

final class RealmFindingsRepositoryTests: XCTestCase {
    private var configuration: Realm.Configuration!
    private var sut: RealmFindingsRepository!

    override func setUp() {
        super.setUp()
        configuration = Realm.Configuration(
            inMemoryIdentifier: "RealmFindingsRepositoryTests.\(UUID().uuidString)"
        )
        sut = RealmFindingsRepository(configuration: configuration)
    }

    override func tearDown() {
        sut = nil
        configuration = nil
        super.tearDown()
    }

    func test_getAllReturnsEmptyArrayWhenNoFindingsExist() throws {
        XCTAssertEqual(try sut.getAll(), [])
    }

    func test_getAllMapsStoredFindingToDomainSummary() throws {
        let id = UUID()
        let imageData = Data([1, 2, 3])
        try store(
            makeFinding(
                id: id,
                taxonName: "Common kingfisher",
                developmentStageName: "Adult",
                imageData: imageData,
                isUploaded: true
            )
        )

        let finding = try XCTUnwrap(sut.getAll().first)

        XCTAssertEqual(finding.id, id)
        XCTAssertEqual(finding.taxonName, "Common kingfisher")
        XCTAssertEqual(finding.developmentStageName, "Adult")
        XCTAssertEqual(finding.thumbnailData, imageData)
        XCTAssertEqual(finding.uploadStatus, .uploaded)
    }

    func test_getAllMapsEmptyImageDataToNilThumbnail() throws {
        try store(makeFinding(imageData: Data()))

        let finding = try XCTUnwrap(sut.getAll().first)

        XCTAssertNil(finding.thumbnailData)
    }

    func test_deleteRemovesOnlyRequestedFinding() throws {
        let deletedID = UUID()
        let remainingID = UUID()
        try store(makeFinding(id: deletedID))
        try store(makeFinding(id: remainingID))

        try sut.delete(id: deletedID)

        XCTAssertEqual(try sut.getAll().map(\.id), [remainingID])
    }

    func test_deleteThrowsNotFoundForUnknownID() {
        let missingID = UUID()

        XCTAssertThrowsError(try sut.delete(id: missingID)) { error in
            XCTAssertEqual(
                error as? FindingsRepositoryError,
                .findingNotFound(missingID)
            )
        }
    }

    func test_deleteAllRemovesEveryFinding() throws {
        try store(makeFinding())
        try store(makeFinding())

        try sut.deleteAll()

        XCTAssertEqual(try sut.getAll(), [])
    }

    private func store(_ finding: DBFinding) throws {
        let realm = try Realm(configuration: configuration)
        try realm.write {
            realm.add(finding)
        }
    }

    private func makeFinding(
        id: UUID = UUID(),
        taxonName: String = "European bee-eater",
        developmentStageName: String = "Adult",
        imageData: Data? = nil,
        isUploaded: Bool = false
    ) -> DBFinding {
        let finding = DBFinding()
        finding.id = id
        finding.taxon = DBFindingTaxon(
            apiId: 1,
            name: taxonName,
            isAtlasCode: false,
            translation: List<DBTaxonTranslations>(),
            devStage: List<DBTaxonDevStage>()
        )
        finding.devStage = DBTaxonDevStage(
            id: 1,
            name: developmentStageName,
            taxonId: 1
        )
        if let imageData {
            finding.images.append(
                DBFindingImage(name: "thumbnail", image: imageData, url: nil)
            )
        }
        finding.isUploaded = isUploaded
        return finding
    }
}
