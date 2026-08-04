import Combine
import XCTest
@testable import Biologer

@MainActor
final class FindingDetailsV2ViewModelTests: XCTestCase {
    func test_loadDetailsPublishesRepositoryContent() {
        let details = makeDetails(status: .pending)
        let context = makeSUT(details: details)

        context.sut.loadDetails()

        XCTAssertEqual(context.sut.details, details)
        XCTAssertEqual(context.sut.loadState, .content)
    }

    func test_navigationActionsForwardFindingLocationAndPhotos() {
        let photos = [
            FindingPhoto(name: "first.jpg", imageData: Data([1]), remoteURL: nil),
            FindingPhoto(name: "second.jpg", imageData: Data([2]), remoteURL: nil)
        ]
        let details = makeDetails(status: .pending, photos: photos)
        var editedID: UUID?
        var shownLocation: FindingDetailsLocation?
        var shownPhotos: [FindingPhoto]?
        var shownPhotoIndex: Int?
        let context = makeSUT(
            details: details,
            onEdit: { editedID = $0 },
            onShowLocation: { shownLocation = $0 },
            onShowPhotos: { photos, index in
                shownPhotos = photos
                shownPhotoIndex = index
            }
        )
        context.sut.loadDetails()

        context.sut.didTapEdit()
        context.sut.didTapShowLocation()
        context.sut.didTapPhoto(at: 1)

        XCTAssertEqual(editedID, details.id)
        XCTAssertEqual(shownLocation, details.location)
        XCTAssertEqual(shownPhotos, photos)
        XCTAssertEqual(shownPhotoIndex, 1)
    }

    func test_uploadShowsSpinnerThenReloadsUploadedDetails() async {
        let pendingDetails = makeDetails(status: .pending)
        let uploadedDetails = makeDetails(
            id: pendingDetails.id,
            status: .uploaded
        )
        let context = makeSUT(details: pendingDetails)
        let completed = expectation(description: "single upload completed")
        context.uploadFindings.onCompletion = {
            context.getDetails.result = .success(uploadedDetails)
            completed.fulfill()
        }
        context.sut.loadDetails()

        context.sut.didTapUpload()

        XCTAssertTrue(context.sut.isUploading)
        await fulfillment(of: [completed], timeout: 1)
        await Task.yield()
        XCTAssertEqual(context.uploadFindings.receivedIDs, [[pendingDetails.id]])
        XCTAssertEqual(context.getDetails.callCount, 2)
        XCTAssertEqual(context.sut.details, uploadedDetails)
        XCTAssertEqual(context.sut.uploadState, .idle)
    }

    func test_uploadFailurePublishesDismissibleErrorWithoutReloading() async {
        let details = makeDetails(status: .pending)
        let context = makeSUT(details: details)
        let failed = expectation(description: "single upload failed")
        context.uploadFindings.result = .failure(FindingDetailsTestError.any)
        let failureObservation = context.sut.$uploadState
            .sink { state in
                if case .failure = state {
                    failed.fulfill()
                }
            }
        context.sut.loadDetails()

        context.sut.didTapUpload()

        await fulfillment(of: [failed], timeout: 1)
        XCTAssertTrue(context.sut.hasUploadError)
        XCTAssertEqual(context.getDetails.callCount, 1)

        context.sut.dismissUploadError()
        XCTAssertEqual(context.sut.uploadState, .idle)
        withExtendedLifetime(failureObservation) {}
    }

    func test_didTapUploadDoesNothingForUploadedFinding() async {
        let details = makeDetails(status: .uploaded)
        let context = makeSUT(details: details)
        context.sut.loadDetails()

        context.sut.didTapUpload()
        await Task.yield()

        XCTAssertEqual(context.uploadFindings.receivedIDs, [])
        XCTAssertEqual(context.sut.uploadState, .idle)
    }

    func test_unverifiedUserCannotUploadPendingFinding() async {
        let details = makeDetails(status: .pending)
        let context = makeSUT(
            details: details,
            isSubmissionAllowed: false
        )
        context.sut.loadDetails()

        context.sut.didTapUpload()
        await Task.yield()

        XCTAssertTrue(context.sut.showsSubmissionWarning)
        XCTAssertEqual(context.uploadFindings.receivedIDs, [])
        XCTAssertEqual(context.sut.uploadState, .idle)

        context.sut.dismissSubmissionWarning()
        XCTAssertFalse(context.sut.showsSubmissionWarning)
    }

    private func makeSUT(
        details: FindingDetails,
        onEdit: @escaping (UUID) -> Void = { _ in },
        onShowLocation: @escaping (FindingDetailsLocation) -> Void = { _ in },
        onShowPhotos: @escaping ([FindingPhoto], Int) -> Void = { _, _ in },
        isSubmissionAllowed: Bool = true
    ) -> FindingDetailsV2TestContext {
        let getDetails = FindingDetailsUseCaseStub(result: .success(details))
        let uploadFindings = FindingDetailsUploadUseCaseSpy()
        let sut = FindingDetailsV2ViewModel(
            findingID: details.id,
            getFindingDetails: getDetails,
            uploadFindings: uploadFindings,
            checkSubmissionAccess: FindingDetailsSubmissionAccessUseCaseStub(
                isAllowed: isSubmissionAllowed
            ),
            onEditFinding: onEdit,
            onShowLocation: onShowLocation,
            onShowPhotos: onShowPhotos
        )
        return FindingDetailsV2TestContext(
            sut: sut,
            getDetails: getDetails,
            uploadFindings: uploadFindings
        )
    }

    private func makeDetails(
        id: UUID = UUID(),
        status: FindingUploadStatus,
        photos: [FindingPhoto] = []
    ) -> FindingDetails {
        FindingDetails(
            id: id,
            taxonName: "Common kingfisher",
            photos: photos,
            developmentStageName: "Adult",
            atlasCodeName: nil,
            location: FindingDetailsLocation(
                latitude: 44.8,
                longitude: 20.4,
                altitude: 120,
                accuracy: 4
            ),
            individuals: FindingDetailsIndividuals(
                total: 1,
                male: nil,
                female: nil
            ),
            observations: [],
            comment: nil,
            habitat: nil,
            foundOn: nil,
            foundDead: nil,
            uploadStatus: status,
            createdAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }
}

@MainActor
private struct FindingDetailsV2TestContext {
    let sut: FindingDetailsV2ViewModel
    let getDetails: FindingDetailsUseCaseStub
    let uploadFindings: FindingDetailsUploadUseCaseSpy
}

private enum FindingDetailsTestError: Error {
    case any
}

private struct FindingDetailsSubmissionAccessUseCaseStub: CheckFindingSubmissionAccessUseCase {
    let isAllowed: Bool

    func execute() -> Bool {
        isAllowed
    }
}

private final class FindingDetailsUseCaseStub: GetFindingDetailsUseCase {
    var result: Result<FindingDetails, Error>
    private(set) var callCount = 0

    init(result: Result<FindingDetails, Error>) {
        self.result = result
    }

    func execute(id: UUID) throws -> FindingDetails {
        callCount += 1
        return try result.get()
    }
}

private final class FindingDetailsUploadUseCaseSpy: UploadFindingsUseCase {
    var result: Result<Void, Error> = .success(())
    var onCompletion: (() -> Void)?
    private(set) var receivedIDs: [[UUID]] = []

    func execute(
        ids: [UUID],
        onProgress: @escaping (FindingUploadProgress) async -> Void
    ) async throws {
        receivedIDs.append(ids)
        await onProgress(
            FindingUploadProgress(completedCount: 0, totalCount: ids.count)
        )

        do {
            try result.get()
            await onProgress(
                FindingUploadProgress(
                    completedCount: ids.count,
                    totalCount: ids.count
                )
            )
            onCompletion?()
        } catch {
            onCompletion?()
            throw error
        }
    }
}
