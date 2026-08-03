import XCTest
@testable import Biologer

final class UploadFindingsUseCaseTests: XCTestCase {
    func test_executeUploadsFindingsSequentiallyAndReportsProgress() async throws {
        let ids = [UUID(), UUID(), UUID()]
        let repository = UploadFindingRepositorySpy()
        let progressRecorder = FindingUploadProgressRecorder()
        let sut = DefaultUploadFindingsUseCase(repository: repository)

        try await sut.execute(ids: ids) { progress in
            await progressRecorder.append(progress)
        }

        let receivedIDs = await repository.receivedIDs
        let progresses = await progressRecorder.values
        XCTAssertEqual(receivedIDs, ids)
        XCTAssertEqual(
            progresses,
            [
                FindingUploadProgress(completedCount: 0, totalCount: 3),
                FindingUploadProgress(completedCount: 1, totalCount: 3),
                FindingUploadProgress(completedCount: 2, totalCount: 3),
                FindingUploadProgress(completedCount: 3, totalCount: 3)
            ]
        )
    }

    func test_executeStopsAtFirstRepositoryFailure() async {
        let ids = [UUID(), UUID(), UUID()]
        let repository = UploadFindingRepositorySpy(failingID: ids[1])
        let progressRecorder = FindingUploadProgressRecorder()
        let sut = DefaultUploadFindingsUseCase(repository: repository)

        do {
            try await sut.execute(ids: ids) { progress in
                await progressRecorder.append(progress)
            }
            XCTFail("Expected upload to fail")
        } catch {
            XCTAssertEqual(error as? UploadFindingsTestError, .uploadFailed)
        }

        let receivedIDs = await repository.receivedIDs
        let progresses = await progressRecorder.values
        XCTAssertEqual(receivedIDs, [ids[0], ids[1]])
        XCTAssertEqual(
            progresses,
            [
                FindingUploadProgress(completedCount: 0, totalCount: 3),
                FindingUploadProgress(completedCount: 1, totalCount: 3)
            ]
        )
    }

    func test_executeWithNoIDsOnlyReportsInitialProgress() async throws {
        let repository = UploadFindingRepositorySpy()
        let progressRecorder = FindingUploadProgressRecorder()
        let sut = DefaultUploadFindingsUseCase(repository: repository)

        try await sut.execute(ids: []) { progress in
            await progressRecorder.append(progress)
        }

        let receivedIDs = await repository.receivedIDs
        let progresses = await progressRecorder.values
        XCTAssertEqual(receivedIDs, [])
        XCTAssertEqual(
            progresses,
            [FindingUploadProgress(completedCount: 0, totalCount: 0)]
        )
    }
}

private enum UploadFindingsTestError: Error, Equatable {
    case uploadFailed
}

private actor UploadFindingRepositorySpy: FindingUploadRepository {
    private(set) var receivedIDs: [UUID] = []
    private let failingID: UUID?

    init(failingID: UUID? = nil) {
        self.failingID = failingID
    }

    func upload(id: UUID) async throws {
        receivedIDs.append(id)
        if id == failingID {
            throw UploadFindingsTestError.uploadFailed
        }
    }
}

private actor FindingUploadProgressRecorder {
    private(set) var values: [FindingUploadProgress] = []

    func append(_ progress: FindingUploadProgress) {
        values.append(progress)
    }
}
