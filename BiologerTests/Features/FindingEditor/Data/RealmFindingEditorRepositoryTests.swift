import RealmSwift
import XCTest
@testable import Biologer

final class RealmFindingEditorRepositoryTests: XCTestCase {
    private var configuration: Realm.Configuration!
    private var sut: RealmFindingEditorRepository!

    override func setUp() {
        super.setUp()
        configuration = Realm.Configuration(
            inMemoryIdentifier: "RealmFindingEditorRepositoryTests.\(UUID().uuidString)"
        )
        sut = RealmFindingEditorRepository(configuration: configuration)
    }

    override func tearDown() {
        sut = nil
        configuration = nil
        super.tearDown()
    }

    func test_createAndGetDraftRoundTripsEditorData() throws {
        let draft = makeDraft()

        try sut.create(draft)
        let storedDraft = try sut.getDraft(id: draft.id)

        XCTAssertEqual(storedDraft.id, draft.id)
        XCTAssertEqual(storedDraft.location, draft.location)
        XCTAssertEqual(storedDraft.photos.map(\.name), draft.photos.map(\.name))
        XCTAssertEqual(storedDraft.photos.map(\.imageData), draft.photos.map(\.imageData))
        XCTAssertEqual(storedDraft.taxon, draft.taxon)
        XCTAssertEqual(storedDraft.taxonName, draft.taxonName)
        XCTAssertEqual(storedDraft.atlasCode, draft.atlasCode)
        XCTAssertEqual(storedDraft.developmentStage, draft.developmentStage)
        XCTAssertEqual(storedDraft.individualEntryMode, .gender)
        XCTAssertEqual(storedDraft.maleIndividuals, 3)
        XCTAssertEqual(storedDraft.femaleIndividuals, 4)
        XCTAssertEqual(storedDraft.observations, draft.observations)
        XCTAssertEqual(storedDraft.comment, draft.comment)
        XCTAssertEqual(storedDraft.habitat, draft.habitat)
        XCTAssertEqual(storedDraft.foundOn, draft.foundOn)
        XCTAssertTrue(storedDraft.isFoundDead)
        XCTAssertEqual(storedDraft.causeOfDeath, draft.causeOfDeath)
        XCTAssertFalse(storedDraft.isUploaded)
        XCTAssertEqual(storedDraft.createdAt, draft.createdAt)
    }

    func test_updateReplacesContentAndMarksUploadedFindingPending() throws {
        var draft = makeDraft()
        try sut.create(draft)
        try markUploaded(id: draft.id)
        draft.taxonName = "Alcedo atthis"
        draft.taxon = nil
        draft.individualEntryMode = .total
        draft.totalIndividuals = 8
        draft.maleIndividuals = 0
        draft.femaleIndividuals = 0
        draft.isFoundDead = false
        draft.causeOfDeath = "Must not be stored"

        try sut.update(draft)
        let storedDraft = try sut.getDraft(id: draft.id)

        XCTAssertEqual(storedDraft.taxonName, "Alcedo atthis")
        XCTAssertEqual(storedDraft.individualEntryMode, .total)
        XCTAssertEqual(storedDraft.totalIndividuals, 8)
        XCTAssertFalse(storedDraft.isFoundDead)
        XCTAssertEqual(storedDraft.causeOfDeath, "")
        XCTAssertFalse(storedDraft.isUploaded)
    }

    func test_getAndUpdateThrowForMissingFinding() {
        let missingID = UUID()

        XCTAssertThrowsError(try sut.getDraft(id: missingID)) { error in
            XCTAssertEqual(
                error as? FindingEditorRepositoryError,
                .findingNotFound(missingID)
            )
        }

        var draft = makeDraft()
        draft.id = missingID
        XCTAssertThrowsError(try sut.update(draft)) { error in
            XCTAssertEqual(
                error as? FindingEditorRepositoryError,
                .findingNotFound(missingID)
            )
        }
    }

    func test_makeNewDraftMapsStoredObservationsWithoutUnsafeIndexing() throws {
        let realm = try Realm(configuration: configuration)
        let observation = DBObservation(
            id: 7,
            translation: List<DBObservationTranslation>()
        )
        observation.translation.append(
            DBObservationTranslation(id: 1, local: "en", name: "Calling")
        )
        try realm.write { realm.add(observation) }

        let draft = try sut.makeNewDraft()

        XCTAssertEqual(draft.observations.count, 1)
        XCTAssertEqual(draft.observations.first?.id, 7)
        XCTAssertEqual(draft.observations.first?.name, "Calling")
        XCTAssertEqual(draft.observations.first?.isSelected, false)
        XCTAssertEqual(draft.totalIndividuals, 1)
    }

    private func makeDraft() -> FindingEditorDraft {
        let createdAt = Date(timeIntervalSince1970: 1_700_000_000)
        let taxon = FindingEditorTaxon(
            apiID: 42,
            name: "Salamandra salamandra",
            usesAtlasCodes: true,
            developmentStages: [
                FindingEditorOption(id: 1, name: "Larva"),
                FindingEditorOption(id: 2, name: "Adult")
            ],
            translations: [
                FindingEditorTaxonTranslation(
                    id: 11,
                    taxonID: 42,
                    locale: "en",
                    nativeName: "Fire salamander",
                    details: ""
                )
            ]
        )
        return FindingEditorDraft(
            id: UUID(),
            location: FindingEditorLocation(
                latitude: 44.8,
                longitude: 20.4,
                altitude: 120,
                accuracy: 4
            ),
            photos: [
                FindingEditorPhoto(
                    name: "photo.jpg",
                    imageData: Data([1, 2, 3]),
                    remoteURL: nil
                )
            ],
            taxon: taxon,
            taxonName: taxon.name,
            atlasCode: FindingEditorOption(id: 3, name: "Possible breeding"),
            developmentStage: FindingEditorOption(id: 2, name: "Adult"),
            individualEntryMode: .gender,
            totalIndividuals: 0,
            maleIndividuals: 3,
            femaleIndividuals: 4,
            observations: [
                FindingEditorObservation(id: 1, name: "Calling", isSelected: true),
                FindingEditorObservation(id: 2, name: "Exuviae", isSelected: false)
            ],
            comment: "Comment",
            habitat: "Forest",
            foundOn: "Leaf litter",
            isFoundDead: true,
            causeOfDeath: "Traffic",
            isUploaded: false,
            createdAt: createdAt
        )
    }

    private func markUploaded(id: UUID) throws {
        let realm = try Realm(configuration: configuration)
        let finding = try XCTUnwrap(
            realm.object(ofType: DBFinding.self, forPrimaryKey: id)
        )
        try realm.write { finding.isUploaded = true }
    }
}
