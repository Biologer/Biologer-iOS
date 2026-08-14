import RealmSwift
import UIKit
import XCTest
@testable import Biologer

@MainActor
final class RealmFindingUploadRepositoryTests: XCTestCase {
    private var configuration: Realm.Configuration!
    private var realm: Realm!
    private var remoteRepository: FindingRemoteUploadRepositorySpy!
    private var sut: RealmFindingUploadRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        configuration = Realm.Configuration(
            inMemoryIdentifier: "RealmFindingUploadRepositoryTests.\(UUID().uuidString)"
        )
        realm = try Realm(configuration: configuration)
        remoteRepository = FindingRemoteUploadRepositorySpy()

        let settings = Settings()
        settings.setProjectName(name: "Wetland survey")
        sut = RealmFindingUploadRepository(
            configuration: configuration,
            remoteRepository: remoteRepository,
            licenseStorage: FindingUploadLicenseStorageStub(
                ids: [.data: 30, .image: 40]
            ),
            licenseOptionsProvider: DefaultLicenseOptionsProvider(),
            settingsStorage: FindingUploadSettingsStorageStub(settings: settings)
        )
    }

    override func tearDown() {
        sut = nil
        remoteRepository = nil
        realm = nil
        configuration = nil
        super.tearDown()
    }

    func test_uploadMapsSnapshotUploadsImageAndMarksFindingAsUploaded() async throws {
        let imageData = try XCTUnwrap(UIImage(systemName: "leaf")?.pngData())
        let finding = makeFinding(imageData: imageData)
        try storeObservationTypes(ids: [101, 202])
        try store(finding)
        remoteRepository.imageResults = ["remote/leaf.jpg"]

        try await sut.upload(id: finding.id)

        let body = try XCTUnwrap(remoteRepository.receivedBodies.first)
        XCTAssertEqual(body.data_license, "30")
        XCTAssertEqual(body.project, "Wetland survey")
        XCTAssertEqual(body.taxon_id, 55)
        XCTAssertEqual(body.taxon_suggestion, "Salamandra salamandra")
        XCTAssertEqual(body.number, 2)
        XCTAssertEqual(body.sex, "")
        XCTAssertEqual(body.observation_types_ids, [101, 202])
        XCTAssertEqual(body.photos?.first?.license, "40")
        XCTAssertEqual(body.photos?.first?.path, "remote/leaf.jpg")
        XCTAssertEqual(remoteRepository.imageCallCount, 1)
        XCTAssertEqual(
            remoteRepository.receivedImageData.first?.starts(with: [0xFF, 0xD8]),
            true
        )

        let assertionRealm = try await Realm(configuration: configuration)
        assertionRealm.refresh()
        XCTAssertEqual(
            assertionRealm.object(
                ofType: DBFinding.self,
                forPrimaryKey: finding.id
            )?.isUploaded,
            true
        )
    }

    func test_uploadCreatesOneRequestAndImageUploadForEachSelectedGender() async throws {
        let imageData = UIImage(systemName: "leaf")?.pngData()
        let finding = makeGenderFinding(imageData: imageData)
        try storeObservationTypes(ids: [101, 202])
        try store(finding)
        remoteRepository.imageResults = ["remote/male.jpg", "remote/female.jpg"]

        try await sut.upload(id: finding.id)

        XCTAssertEqual(remoteRepository.receivedBodies.map(\.sex), ["male", "female"])
        XCTAssertEqual(remoteRepository.receivedBodies.map(\.number), [2, 3])
        XCTAssertEqual(
            remoteRepository.receivedBodies.map { $0.photos?.first?.path },
            ["remote/male.jpg", "remote/female.jpg"]
        )
        XCTAssertEqual(remoteRepository.imageCallCount, 2)

        let assertionRealm = try await Realm(configuration: configuration)
        assertionRealm.refresh()
        let storedFinding = try XCTUnwrap(
            assertionRealm.object(ofType: DBFinding.self, forPrimaryKey: finding.id)
        )
        XCTAssertTrue(storedFinding.individuals?.male?.isUploaded == true)
        XCTAssertTrue(storedFinding.individuals?.female?.isUploaded == true)
        XCTAssertTrue(storedFinding.isUploaded)
    }

    func test_retryAfterPartialGenderFailureOnlyUploadsPendingGender() async throws {
        let finding = makeGenderFinding(imageData: nil)
        try storeObservationTypes(ids: [101, 202])
        try store(finding)
        remoteRepository.queuedFindingResults = [
            .success(()),
            .failure(FindingUploadFailure(message: "Female upload failed"))
        ]

        do {
            try await sut.upload(id: finding.id)
            XCTFail("Expected the female upload to fail")
        } catch {
            XCTAssertEqual(
                error as? FindingUploadFailure,
                FindingUploadFailure(message: "Female upload failed")
            )
        }

        var assertionRealm = try await Realm(configuration: configuration)
        assertionRealm.refresh()
        var storedFinding = try XCTUnwrap(
            assertionRealm.object(ofType: DBFinding.self, forPrimaryKey: finding.id)
        )
        XCTAssertTrue(storedFinding.individuals?.male?.isUploaded == true)
        XCTAssertFalse(storedFinding.individuals?.female?.isUploaded == true)
        XCTAssertFalse(storedFinding.isUploaded)

        remoteRepository.queuedFindingResults = [.success(())]
        try await sut.upload(id: finding.id)

        XCTAssertEqual(
            remoteRepository.receivedBodies.map(\.sex),
            ["male", "female", "female"]
        )
        assertionRealm = try await Realm(configuration: configuration)
        assertionRealm.refresh()
        storedFinding = try XCTUnwrap(
            assertionRealm.object(ofType: DBFinding.self, forPrimaryKey: finding.id)
        )
        XCTAssertTrue(storedFinding.individuals?.male?.isUploaded == true)
        XCTAssertTrue(storedFinding.individuals?.female?.isUploaded == true)
        XCTAssertTrue(storedFinding.isUploaded)
    }

    func test_uploadLeavesFindingPendingWhenRemotePostFails() async throws {
        let finding = makeFinding(imageData: nil)
        try storeObservationTypes(ids: [101, 202])
        try store(finding)
        remoteRepository.findingResult = .failure(
            FindingUploadFailure(message: "Upload failed")
        )

        do {
            try await sut.upload(id: finding.id)
            XCTFail("Expected upload to fail")
        } catch {
            XCTAssertEqual(
                error as? FindingUploadFailure,
                FindingUploadFailure(message: "Upload failed")
            )
        }

        let assertionRealm = try await Realm(configuration: configuration)
        assertionRealm.refresh()
        XCTAssertEqual(
            assertionRealm.object(
                ofType: DBFinding.self,
                forPrimaryKey: finding.id
            )?.isUploaded,
            false
        )
    }

    func test_upload_withInvalidImageData_doesNotCallRemoteOrMarkFindingAsUploaded() async throws {
        // Given
        let finding = makeFinding(imageData: Data([0x00, 0x01, 0x02]))
        try storeObservationTypes(ids: [101, 202])
        try store(finding)

        // When
        var receivedError: Error?
        do {
            try await sut.upload(id: finding.id)
        } catch {
            receivedError = error
        }

        // Then
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(remoteRepository.imageCallCount, 0)
        XCTAssertTrue(remoteRepository.receivedImageData.isEmpty)
        XCTAssertTrue(remoteRepository.receivedBodies.isEmpty)

        let assertionRealm = try await Realm(configuration: configuration)
        assertionRealm.refresh()
        XCTAssertEqual(
            assertionRealm.object(
                ofType: DBFinding.self,
                forPrimaryKey: finding.id
            )?.isUploaded,
            false
        )
    }

    func test_uploadThrowsNotFoundForUnknownFinding() async {
        let missingID = UUID()

        do {
            try await sut.upload(id: missingID)
            XCTFail("Expected missing finding error")
        } catch {
            XCTAssertEqual(
                error as? FindingsRepositoryError,
                .findingNotFound(missingID)
            )
        }
    }

    private func store(_ finding: DBFinding) throws {
        let testRealm = try Realm(configuration: configuration)
        try testRealm.write {
            testRealm.add(finding)
        }
    }

    private func storeObservationTypes(ids: [Int]) throws {
        let testRealm = try Realm(configuration: configuration)
        try testRealm.write {
            ids.forEach { id in
                testRealm.add(
                    DBObservation(
                        id: id,
                        translation: List<DBObservationTranslation>()
                    )
                )
            }
        }
    }

    private func makeFinding(imageData: Data?) -> DBFinding {
        let finding = DBFinding()
        finding.location = DBFindingLocation(
            latitude: 44.8,
            longitude: 20.4,
            altitude: 120,
            accuracy: 4
        )
        finding.taxon = DBFindingTaxon(
            apiId: 55,
            name: "Salamandra salamandra",
            isAtlasCode: false,
            translation: List<DBTaxonTranslations>(),
            devStage: List<DBTaxonDevStage>()
        )
        finding.individuals = DBFindingIndividuals(
            male: nil,
            female: nil,
            all: DBFindingIndividual(value: 2, isSelected: true)
        )
        finding.comment = "Near a stream"
        finding.dateOfCreation = Date(timeIntervalSince1970: 1_700_000_000)
        finding.isUploaded = false

        if let imageData {
            finding.images.append(
                DBFindingImage(name: "leaf", image: imageData, url: nil)
            )
        }
        return finding
    }

    private func makeGenderFinding(imageData: Data?) -> DBFinding {
        let finding = makeFinding(imageData: imageData)
        finding.individuals = DBFindingIndividuals(
            male: DBFindingIndividual(value: 2, isSelected: true),
            female: DBFindingIndividual(value: 3, isSelected: true),
            all: nil
        )
        return finding
    }

}

private final class FindingRemoteUploadRepositorySpy: FindingRemoteUploadRepository {
    var findingResult: Swift.Result<Void, FindingUploadFailure> = .success(())
    var queuedFindingResults: [Swift.Result<Void, FindingUploadFailure>] = []
    private(set) var receivedBodies: [FindingRequestBody] = []
    private(set) var receivedImageData: [Data] = []
    var imageResults: [String] = []
    private(set) var imageCallCount = 0

    func uploadFinding(
        _ body: FindingRequestBody
    ) async throws(FindingUploadFailure) {
        let result = queuedFindingResults.isEmpty ? findingResult : queuedFindingResults.removeFirst()
        receivedBodies.append(body)
        try result.get()
    }

    func uploadImage(
        _ imageData: Data
    ) async throws(FindingUploadFailure) -> String {
        defer { imageCallCount += 1 }
        receivedImageData.append(imageData)
        guard imageResults.indices.contains(imageCallCount) else {
            throw FindingUploadFailure(message: "Missing image response")
        }
        return imageResults[imageCallCount]
    }
}

private final class FindingUploadLicenseStorageStub: LicensePreferenceStorage {
    private var ids: [LicenseKind: Int]

    init(ids: [LicenseKind: Int]) {
        self.ids = ids
    }

    func selectedLicenseID(for kind: LicenseKind) -> Int? {
        ids[kind]
    }

    func saveSelectedLicenseID(_ id: Int, for kind: LicenseKind) {
        ids[kind] = id
    }

}

private final class FindingUploadSettingsStorageStub: SettingsStorage {
    private var settings: Settings?

    init(settings: Settings?) {
        self.settings = settings
    }

    func getSettings() -> Settings? {
        settings
    }

    func saveSettings(settings: Settings) {
        self.settings = settings
    }
}
