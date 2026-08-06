import Combine
import XCTest
@testable import Biologer

@MainActor
final class ListOfFindingsViewModelTests: XCTestCase {
    func test_loadFindingsPublishesContent() {
        let finding = makeFinding()
        let context = makeSUT(getResult: .success([finding]))

        context.sut.loadFindings()

        XCTAssertEqual(context.sut.findings, [finding])
        XCTAssertEqual(context.sut.loadState, .content)
    }

    func test_loadFindingsPublishesEmptyState() {
        let context = makeSUT(getResult: .success([]))

        context.sut.loadFindings()

        XCTAssertEqual(context.sut.findings, [])
        XCTAssertEqual(context.sut.loadState, .empty)
    }

    func test_loadFindingsPublishesFailureAndClearsPreviousContent() {
        let finding = makeFinding()
        let context = makeSUT(getResult: .success([finding]))
        context.sut.loadFindings()
        context.getFindings.result = .failure(FindingsViewModelTestError.any)

        context.sut.loadFindings()

        XCTAssertEqual(context.sut.findings, [])
        XCTAssertEqual(context.sut.loadState, .failure)
    }

    func test_navigationActionsReturnPermissionForAvailableActions() {
        let finding = makeFinding()
        let context = makeSUT(getResult: .success([finding]))
        context.sut.loadFindings()

        let canAddFinding = context.sut.canAddFinding()
        let canSelectFinding = context.sut.canSelectFinding(finding)

        XCTAssertTrue(canAddFinding)
        XCTAssertTrue(canSelectFinding)
    }

    func test_unverifiedUserSeesWarningBeforeCreatingFinding() {
        let context = makeSUT(
            isSubmissionAllowed: false
        )

        let canAddFinding = context.sut.canAddFinding()

        XCTAssertEqual(context.sut.submissionWarning, .createFinding)
        XCTAssertFalse(canAddFinding)

        let shouldContinue = context.sut.confirmSubmissionWarning()

        XCTAssertNil(context.sut.submissionWarning)
        XCTAssertTrue(shouldContinue)
    }

    func test_unverifiedUserCannotBeginUploadSelection() {
        let finding = makeFinding(status: .pending)
        let context = makeSUT(
            getResult: .success([finding]),
            isSubmissionAllowed: false
        )
        context.sut.loadFindings()

        context.sut.beginUploadSelection()

        XCTAssertEqual(context.sut.submissionWarning, .uploadFindings)
        XCTAssertNil(context.sut.selectionMode)
        XCTAssertEqual(context.sut.selectedFindingIDs, [])
    }

    func test_filteringAndUploadSelectionOnlyIncludePendingFindings() {
        let firstPending = makeFinding(status: .pending)
        let uploaded = makeFinding(status: .uploaded)
        let secondPending = makeFinding(status: .pending)
        let context = makeSUT(
            getResult: .success([firstPending, uploaded, secondPending])
        )
        context.sut.loadFindings()

        context.sut.selectFilter(.uploaded)
        XCTAssertEqual(context.sut.visibleFindings, [uploaded])

        context.sut.beginUploadSelection()
        XCTAssertEqual(context.sut.selectedFilter, .pending)
        XCTAssertEqual(
            context.sut.visibleFindings,
            [firstPending, secondPending]
        )

        context.sut.toggleAllSelectableFindings()
        XCTAssertEqual(
            context.sut.selectedFindingIDs,
            Set([firstPending.id, secondPending.id])
        )
    }

    func test_uploadSelectedFindingsPublishesProgressAndReloads() async {
        let first = makeFinding(status: .pending)
        let second = makeFinding(status: .pending)
        let context = makeSUT(getResult: .success([first, second]))
        let completed = expectation(description: "upload completed")
        context.uploadFindings.onCompletion = { completed.fulfill() }
        context.sut.loadFindings()
        context.sut.beginUploadSelection()
        context.sut.toggleAllSelectableFindings()

        context.sut.uploadSelectedFindings()

        XCTAssertTrue(context.sut.isUploading)
        await fulfillment(of: [completed], timeout: 1)
        await Task.yield()
        XCTAssertEqual(context.uploadFindings.receivedIDs, [[first.id, second.id]])
        XCTAssertEqual(context.getFindings.callCount, 2)
        XCTAssertEqual(context.sut.uploadState, .idle)
    }

    func test_uploadFailurePublishesCompletedCountAndReloads() async {
        let first = makeFinding(status: .pending)
        let second = makeFinding(status: .pending)
        let context = makeSUT(getResult: .success([first, second]))
        let failed = expectation(description: "upload failed")
        context.uploadFindings.progresses = [
            FindingUploadProgress(completedCount: 0, totalCount: 2),
            FindingUploadProgress(completedCount: 1, totalCount: 2)
        ]
        context.uploadFindings.result = .failure(FindingsViewModelTestError.any)
        let failureObservation = context.sut.$actionError
            .compactMap { $0 }
            .sink { error in
                if error == .uploadFindings(completedCount: 1, totalCount: 2) {
                    failed.fulfill()
                }
            }
        context.sut.loadFindings()
        context.sut.beginUploadSelection()
        context.sut.toggleAllSelectableFindings()

        context.sut.uploadSelectedFindings()

        await fulfillment(of: [failed], timeout: 1)
        XCTAssertEqual(
            context.sut.actionError,
            .uploadFindings(completedCount: 1, totalCount: 2)
        )
        XCTAssertEqual(context.getFindings.callCount, 2)
        withExtendedLifetime(failureObservation) {}
    }

    func test_deletionSelectionIncludesEveryFindingAndRestoresPreviousFilter() {
        let pending = makeFinding(status: .pending)
        let uploaded = makeFinding(status: .uploaded)
        let context = makeSUT(getResult: .success([pending, uploaded]))
        context.sut.loadFindings()
        context.sut.selectFilter(.uploaded)

        context.sut.beginDeletionSelection()
        context.sut.toggleAllSelectableFindings()

        XCTAssertEqual(context.sut.selectionMode, .deletion)
        XCTAssertEqual(context.sut.selectedFilter, .all)
        XCTAssertEqual(
            context.sut.selectedFindingIDs,
            Set([pending.id, uploaded.id])
        )

        context.sut.cancelSelection()

        XCTAssertNil(context.sut.selectionMode)
        XCTAssertEqual(context.sut.selectedFindingIDs, [])
        XCTAssertEqual(context.sut.selectedFilter, .uploaded)
    }

    func test_deleteSelectedFindingsDeletesSelectionAndReloadsOnce() {
        let first = makeFinding(status: .pending)
        let second = makeFinding(status: .uploaded)
        let unselected = makeFinding(status: .pending)
        let context = makeSUT(
            getResult: .success([first, second, unselected])
        )
        context.sut.loadFindings()
        context.sut.beginDeletionSelection()
        context.sut.toggleSelection(for: first)
        context.sut.toggleSelection(for: second)

        context.sut.deleteSelectedFindings()

        XCTAssertEqual(
            context.deleteFindings.receivedIDBatches,
            [[first.id, second.id]]
        )
        XCTAssertEqual(context.getFindings.callCount, 2)
        XCTAssertNil(context.sut.selectionMode)
        XCTAssertEqual(context.sut.selectedFindingIDs, [])
        XCTAssertNil(context.sut.actionError)
    }

    func test_deleteSelectedFindingsPublishesErrorAndReloadsCurrentContent() {
        let finding = makeFinding()
        let context = makeSUT(getResult: .success([finding]))
        context.deleteFindings.result = .failure(FindingsViewModelTestError.any)
        context.sut.loadFindings()
        context.sut.beginDeletionSelection()
        context.sut.toggleSelection(for: finding)

        context.sut.deleteSelectedFindings()

        XCTAssertEqual(context.deleteFindings.receivedIDBatches, [[finding.id]])
        XCTAssertEqual(context.getFindings.callCount, 2)
        XCTAssertEqual(context.sut.actionError, .deleteFindings)
        XCTAssertNil(context.sut.selectionMode)
    }

    func test_deleteFindingDeletesRequestedIDAndReloadsContent() {
        let deletedID = UUID()
        let remainingFinding = makeFinding()
        let context = makeSUT(getResult: .success([remainingFinding]))

        context.sut.deleteFinding(id: deletedID)

        XCTAssertEqual(context.deleteFinding.receivedIDs, [deletedID])
        XCTAssertEqual(context.getFindings.callCount, 1)
        XCTAssertEqual(context.sut.findings, [remainingFinding])
        XCTAssertEqual(context.sut.loadState, .content)
        XCTAssertNil(context.sut.actionError)
    }

    func test_deleteFindingPublishesActionErrorWithoutReloading() {
        let context = makeSUT()
        context.deleteFinding.result = .failure(FindingsViewModelTestError.any)

        context.sut.deleteFinding(id: UUID())

        XCTAssertEqual(context.sut.actionError, .deleteFinding)
        XCTAssertEqual(context.getFindings.callCount, 0)
    }

    func test_deleteAllFindingsDeletesAndReloadsEmptyState() {
        let context = makeSUT(getResult: .success([]))

        context.sut.deleteAllFindings()

        XCTAssertEqual(context.deleteAllFindings.callCount, 1)
        XCTAssertEqual(context.getFindings.callCount, 1)
        XCTAssertEqual(context.sut.loadState, .empty)
        XCTAssertNil(context.sut.actionError)
    }

    func test_deleteAllFindingsPublishesDismissibleActionError() {
        let context = makeSUT()
        context.deleteAllFindings.result = .failure(FindingsViewModelTestError.any)

        context.sut.deleteAllFindings()
        XCTAssertEqual(context.sut.actionError, .deleteAllFindings)

        context.sut.dismissActionError()
        XCTAssertNil(context.sut.actionError)
    }

    private func makeSUT(
        getResult: Result<[FindingSummary], Error> = .success([]),
        isSubmissionAllowed: Bool = true
    ) -> ListOfFindingsTestContext {
        let getFindings = GetFindingsUseCaseStub(result: getResult)
        let deleteFinding = DeleteFindingUseCaseSpy()
        let deleteFindings = DeleteFindingsUseCaseSpy()
        let deleteAllFindings = DeleteAllFindingsUseCaseSpy()
        let uploadFindings = ListUploadFindingsUseCaseSpy()
        let sut = ListOfFindingsViewModel(
            useCases: ListOfFindingsUseCases(
                getFindings: getFindings,
                deleteFinding: deleteFinding,
                deleteFindings: deleteFindings,
                deleteAllFindings: deleteAllFindings,
                uploadFindings: uploadFindings,
                checkSubmissionAccess: FindingSubmissionAccessUseCaseStub(
                    isAllowed: isSubmissionAllowed
                )
            )
        )
        return ListOfFindingsTestContext(
            sut: sut,
            getFindings: getFindings,
            deleteFinding: deleteFinding,
            deleteFindings: deleteFindings,
            deleteAllFindings: deleteAllFindings,
            uploadFindings: uploadFindings
        )
    }

    private func makeFinding(
        status: FindingUploadStatus = .pending
    ) -> FindingSummary {
        FindingSummary(
            id: UUID(),
            taxonName: "Common kingfisher",
            thumbnailData: nil,
            developmentStageName: "Adult",
            uploadStatus: status
        )
    }
}

@MainActor
private struct ListOfFindingsTestContext {
    let sut: ListOfFindingsViewModel
    let getFindings: GetFindingsUseCaseStub
    let deleteFinding: DeleteFindingUseCaseSpy
    let deleteFindings: DeleteFindingsUseCaseSpy
    let deleteAllFindings: DeleteAllFindingsUseCaseSpy
    let uploadFindings: ListUploadFindingsUseCaseSpy
}

private enum FindingsViewModelTestError: Error {
    case any
}

private struct FindingSubmissionAccessUseCaseStub: CheckFindingSubmissionAccessUseCase {
    let isAllowed: Bool

    func execute() -> Bool {
        isAllowed
    }
}

private final class GetFindingsUseCaseStub: GetFindingsUseCase {
    var result: Result<[FindingSummary], Error>
    private(set) var callCount = 0

    init(result: Result<[FindingSummary], Error>) {
        self.result = result
    }

    func execute() throws -> [FindingSummary] {
        callCount += 1
        return try result.get()
    }
}

private final class DeleteFindingUseCaseSpy: DeleteFindingUseCase {
    var result: Result<Void, Error> = .success(())
    private(set) var receivedIDs: [UUID] = []

    func execute(id: UUID) throws {
        receivedIDs.append(id)
        try result.get()
    }
}

private final class DeleteFindingsUseCaseSpy: DeleteFindingsUseCase {
    var result: Result<Void, Error> = .success(())
    private(set) var receivedIDBatches: [[UUID]] = []

    func execute(ids: [UUID]) throws {
        receivedIDBatches.append(ids)
        try result.get()
    }
}

private final class DeleteAllFindingsUseCaseSpy: DeleteAllFindingsUseCase {
    var result: Result<Void, Error> = .success(())
    private(set) var callCount = 0

    func execute() throws {
        callCount += 1
        try result.get()
    }
}

private final class ListUploadFindingsUseCaseSpy: UploadFindingsUseCase {
    var result: Result<Void, Error> = .success(())
    var progresses: [FindingUploadProgress] = []
    var onCompletion: (() -> Void)?
    private(set) var receivedIDs: [[UUID]] = []

    func execute(
        ids: [UUID],
        onProgress: @escaping (FindingUploadProgress) async -> Void
    ) async throws {
        receivedIDs.append(ids)

        let reportedProgresses = progresses.isEmpty
            ? [
                FindingUploadProgress(completedCount: 0, totalCount: ids.count),
                FindingUploadProgress(
                    completedCount: ids.count,
                    totalCount: ids.count
                )
            ]
            : progresses

        for progress in reportedProgresses {
            await onProgress(progress)
        }

        do {
            try result.get()
            onCompletion?()
        } catch {
            onCompletion?()
            throw error
        }
    }
}
