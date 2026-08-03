import XCTest
@testable import Biologer

@MainActor
final class ListOfFindingsV2ViewModelTests: XCTestCase {
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

    func test_navigationActionsForwardCallbacks() {
        let finding = makeFinding()
        var addCallCount = 0
        var selectedFindingID: UUID?
        let context = makeSUT(
            onAddFinding: { addCallCount += 1 },
            onFindingSelected: { selectedFindingID = $0 }
        )

        context.sut.didTapAddFinding()
        context.sut.didSelectFinding(finding)

        XCTAssertEqual(addCallCount, 1)
        XCTAssertEqual(selectedFindingID, finding.id)
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
        onAddFinding: @escaping () -> Void = {},
        onFindingSelected: @escaping (UUID) -> Void = { _ in }
    ) -> ListOfFindingsV2TestContext {
        let getFindings = GetFindingsUseCaseStub(result: getResult)
        let deleteFinding = DeleteFindingUseCaseSpy()
        let deleteAllFindings = DeleteAllFindingsUseCaseSpy()
        let sut = ListOfFindingsV2ViewModel(
            useCases: FindingsUseCases(
                getFindings: getFindings,
                deleteFinding: deleteFinding,
                deleteAllFindings: deleteAllFindings
            ),
            onAddFinding: onAddFinding,
            onFindingSelected: onFindingSelected
        )
        return ListOfFindingsV2TestContext(
            sut: sut,
            getFindings: getFindings,
            deleteFinding: deleteFinding,
            deleteAllFindings: deleteAllFindings
        )
    }

    private func makeFinding() -> FindingSummary {
        FindingSummary(
            id: UUID(),
            taxonName: "Common kingfisher",
            thumbnailData: nil,
            developmentStageName: "Adult",
            uploadStatus: .pending
        )
    }
}

@MainActor
private struct ListOfFindingsV2TestContext {
    let sut: ListOfFindingsV2ViewModel
    let getFindings: GetFindingsUseCaseStub
    let deleteFinding: DeleteFindingUseCaseSpy
    let deleteAllFindings: DeleteAllFindingsUseCaseSpy
}

private enum FindingsViewModelTestError: Error {
    case any
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

private final class DeleteAllFindingsUseCaseSpy: DeleteAllFindingsUseCase {
    var result: Result<Void, Error> = .success(())
    private(set) var callCount = 0

    func execute() throws {
        callCount += 1
        try result.get()
    }
}
