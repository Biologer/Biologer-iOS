import XCTest
@testable import Biologer

final class FindingsUseCaseTests: XCTestCase {
    func test_getFindingsReturnsRepositoryFindings() throws {
        let expectedFindings = [makeFinding()]
        let repository = FindingsRepositorySpy()
        repository.getAllResult = .success(expectedFindings)
        let sut = DefaultGetFindingsUseCase(repository: repository)

        let findings = try sut.execute()

        XCTAssertEqual(findings, expectedFindings)
    }

    func test_getFindingsForwardsRepositoryError() {
        let repository = FindingsRepositorySpy()
        repository.getAllResult = .failure(FindingsUseCaseTestError.any)
        let sut = DefaultGetFindingsUseCase(repository: repository)

        XCTAssertThrowsError(try sut.execute()) { error in
            XCTAssertTrue(error is FindingsUseCaseTestError)
        }
    }

    func test_deleteFindingForwardsIDToRepository() throws {
        let id = UUID()
        let repository = FindingsRepositorySpy()
        let sut = DefaultDeleteFindingUseCase(repository: repository)

        try sut.execute(id: id)

        XCTAssertEqual(repository.deletedFindingIDs, [id])
    }

    func test_deleteFindingForwardsRepositoryError() {
        let repository = FindingsRepositorySpy()
        repository.deleteResult = .failure(FindingsUseCaseTestError.any)
        let sut = DefaultDeleteFindingUseCase(repository: repository)

        XCTAssertThrowsError(try sut.execute(id: UUID())) { error in
            XCTAssertTrue(error is FindingsUseCaseTestError)
        }
    }

    func test_deleteAllFindingsDelegatesToRepository() throws {
        let repository = FindingsRepositorySpy()
        let sut = DefaultDeleteAllFindingsUseCase(repository: repository)

        try sut.execute()

        XCTAssertEqual(repository.deleteAllCallCount, 1)
    }

    func test_deleteAllFindingsForwardsRepositoryError() {
        let repository = FindingsRepositorySpy()
        repository.deleteAllResult = .failure(FindingsUseCaseTestError.any)
        let sut = DefaultDeleteAllFindingsUseCase(repository: repository)

        XCTAssertThrowsError(try sut.execute()) { error in
            XCTAssertTrue(error is FindingsUseCaseTestError)
        }
    }

    private func makeFinding() -> FindingSummary {
        FindingSummary(
            id: UUID(),
            taxonName: "Common kingfisher",
            thumbnailData: Data([1, 2, 3]),
            developmentStageName: "Adult",
            uploadStatus: .pending
        )
    }
}

private enum FindingsUseCaseTestError: Error {
    case any
}

private final class FindingsRepositorySpy: FindingsRepository {
    var getAllResult: Result<[FindingSummary], Error> = .success([])
    var deleteResult: Result<Void, Error> = .success(())
    var deleteAllResult: Result<Void, Error> = .success(())
    private(set) var deletedFindingIDs: [UUID] = []
    private(set) var deleteAllCallCount = 0

    func getAll() throws -> [FindingSummary] {
        try getAllResult.get()
    }

    func delete(id: UUID) throws {
        deletedFindingIDs.append(id)
        try deleteResult.get()
    }

    func deleteAll() throws {
        deleteAllCallCount += 1
        try deleteAllResult.get()
    }
}
