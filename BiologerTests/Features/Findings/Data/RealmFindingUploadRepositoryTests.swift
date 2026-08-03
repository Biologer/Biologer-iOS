import RealmSwift
import UIKit
import XCTest
@testable import Biologer

@MainActor
final class RealmFindingUploadRepositoryTests: XCTestCase {
    private var configuration: Realm.Configuration!
    private var realm: Realm!
    private var postFindingService: PostFindingServiceSpy!
    private var postImageService: PostFindingImageServiceSpy!
    private var sut: RealmFindingUploadRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        configuration = Realm.Configuration(
            inMemoryIdentifier: "RealmFindingUploadRepositoryTests.\(UUID().uuidString)"
        )
        realm = try Realm(configuration: configuration)
        postFindingService = PostFindingServiceSpy()
        postImageService = PostFindingImageServiceSpy()

        let settings = Settings()
        settings.setProjectName(name: "Wetland survey")
        sut = RealmFindingUploadRepository(
            configuration: configuration,
            remotePostService: postFindingService,
            uploadImageService: postImageService,
            dataLicenseStorage: FindingUploadLicenseStorageStub(
                license: makeLicense(id: 30, type: .data)
            ),
            imageLicenseStorage: FindingUploadLicenseStorageStub(
                license: makeLicense(id: 40, type: .image)
            ),
            settingsStorage: FindingUploadSettingsStorageStub(settings: settings)
        )
    }

    override func tearDown() {
        sut = nil
        postImageService = nil
        postFindingService = nil
        realm = nil
        configuration = nil
        super.tearDown()
    }

    func test_uploadMapsSnapshotUploadsImageAndMarksFindingAsUploaded() async throws {
        let finding = makeFinding(imageData: UIImage(systemName: "leaf")?.pngData())
        try storeObservationTypes(ids: [101, 202])
        try store(finding)
        postImageService.results = [
            .success(FindingImageResponse(file: "remote/leaf.jpg"))
        ]

        try await sut.upload(id: finding.id)

        let body = try XCTUnwrap(postFindingService.receivedBodies.first)
        XCTAssertEqual(body.data_license, "30")
        XCTAssertEqual(body.project, "Wetland survey")
        XCTAssertEqual(body.taxon_id, 55)
        XCTAssertEqual(body.taxon_suggestion, "Salamandra salamandra")
        XCTAssertEqual(body.number, 2)
        XCTAssertEqual(body.sex, "")
        XCTAssertEqual(body.observation_types_ids, [101, 202])
        XCTAssertEqual(body.photos?.first?.license, "40")
        XCTAssertEqual(body.photos?.first?.path, "remote/leaf.jpg")
        XCTAssertEqual(postImageService.callCount, 1)

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
        postImageService.results = [
            .success(FindingImageResponse(file: "remote/male.jpg")),
            .success(FindingImageResponse(file: "remote/female.jpg"))
        ]

        try await sut.upload(id: finding.id)

        XCTAssertEqual(postFindingService.receivedBodies.map(\.sex), ["male", "female"])
        XCTAssertEqual(postFindingService.receivedBodies.map(\.number), [2, 3])
        XCTAssertEqual(
            postFindingService.receivedBodies.map { $0.photos?.first?.path },
            ["remote/male.jpg", "remote/female.jpg"]
        )
        XCTAssertEqual(postImageService.callCount, 2)

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
        postFindingService.queuedResults = [
            .success(FindingResponse()),
            .failure(APIError(description: "Female upload failed"))
        ]

        do {
            try await sut.upload(id: finding.id)
            XCTFail("Expected the female upload to fail")
        } catch {
            XCTAssertTrue(error is APIError)
        }

        var assertionRealm = try await Realm(configuration: configuration)
        assertionRealm.refresh()
        var storedFinding = try XCTUnwrap(
            assertionRealm.object(ofType: DBFinding.self, forPrimaryKey: finding.id)
        )
        XCTAssertTrue(storedFinding.individuals?.male?.isUploaded == true)
        XCTAssertFalse(storedFinding.individuals?.female?.isUploaded == true)
        XCTAssertFalse(storedFinding.isUploaded)

        postFindingService.queuedResults = [.success(FindingResponse())]
        try await sut.upload(id: finding.id)

        XCTAssertEqual(
            postFindingService.receivedBodies.map(\.sex),
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
        postFindingService.result = .failure(
            APIError(description: "Upload failed")
        )

        do {
            try await sut.upload(id: finding.id)
            XCTFail("Expected upload to fail")
        } catch {
            XCTAssertTrue(error is APIError)
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

    private func makeLicense(
        id: Int,
        type: CheckMarkItemType
    ) -> CheckMarkItem {
        CheckMarkItem(
            id: id,
            title: "License",
            placeholder: "",
            type: type,
            isSelected: true
        )
    }
}

private final class PostFindingServiceSpy: PostFindingService {
    var result: Swift.Result<FindingResponse, APIError> = .success(
        FindingResponse()
    )
    var queuedResults: [Swift.Result<FindingResponse, APIError>] = []
    private(set) var receivedBodies: [FindingRequestBody] = []

    func uploadFinding(
        findingBody: FindingRequestBody,
        completion: @escaping (Swift.Result<FindingResponse, APIError>) -> Void
    ) {
        receivedBodies.append(findingBody)
        completion(queuedResults.isEmpty ? result : queuedResults.removeFirst())
    }
}

private final class PostFindingImageServiceSpy: PostFindingImageService {
    var results: [Swift.Result<FindingImageResponse, APIError>] = []
    private(set) var callCount = 0

    func uploadFindingImages(
        taxonImages: TaxonImage,
        completion: @escaping (Swift.Result<FindingImageResponse, APIError>) -> Void
    ) {
        let result = results.indices.contains(callCount)
            ? results[callCount]
            : .failure(APIError(description: "Missing image response"))
        callCount += 1
        completion(result)
    }
}

private final class FindingUploadLicenseStorageStub: LicenseStorage {
    private var license: CheckMarkItem?

    init(license: CheckMarkItem?) {
        self.license = license
    }

    func getLicense() -> CheckMarkItem? {
        license
    }

    func saveLicense(license: CheckMarkItem) {
        self.license = license
    }

    func delete() {
        license = nil
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

    func delete() {
        settings = nil
    }
}
