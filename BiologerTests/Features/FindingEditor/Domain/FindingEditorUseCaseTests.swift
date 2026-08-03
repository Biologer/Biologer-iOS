import XCTest
@testable import Biologer

final class FindingEditorUseCaseTests: XCTestCase {
    func test_loadCreateReturnsNewRepositoryDraft() throws {
        let expectedDraft = makeDraft()
        let repository = FindingEditorRepositorySpy()
        repository.newDraftResult = .success(expectedDraft)
        let sut = DefaultLoadFindingEditorUseCase(repository: repository)

        let draft = try sut.execute(mode: .create)

        XCTAssertEqual(draft, expectedDraft)
        XCTAssertEqual(repository.makeNewDraftCallCount, 1)
        XCTAssertEqual(repository.requestedDraftIDs, [])
    }

    func test_loadEditRequestsDraftByID() throws {
        let expectedDraft = makeDraft()
        let repository = FindingEditorRepositorySpy()
        repository.getDraftResult = .success(expectedDraft)
        let sut = DefaultLoadFindingEditorUseCase(repository: repository)

        let draft = try sut.execute(mode: .edit(expectedDraft.id))

        XCTAssertEqual(draft, expectedDraft)
        XCTAssertEqual(repository.requestedDraftIDs, [expectedDraft.id])
    }

    func test_saveCreatePersistsSinglePendingFindingWithGenderCounts() throws {
        var draft = makeDraft()
        draft.individualEntryMode = .gender
        draft.totalIndividuals = 0
        draft.maleIndividuals = 3
        draft.femaleIndividuals = 4
        draft.isUploaded = true
        let repository = FindingEditorRepositorySpy()
        let sut = DefaultSaveFindingEditorUseCase(repository: repository)

        let id = try sut.execute(draft: draft, mode: .create)

        XCTAssertEqual(id, draft.id)
        XCTAssertEqual(repository.createdDrafts.count, 1)
        XCTAssertEqual(repository.createdDrafts.first?.maleIndividuals, 3)
        XCTAssertEqual(repository.createdDrafts.first?.femaleIndividuals, 4)
        XCTAssertEqual(repository.createdDrafts.first?.individualEntryMode, .gender)
        XCTAssertEqual(repository.createdDrafts.first?.isUploaded, false)
        XCTAssertEqual(repository.updatedDrafts, [])
    }

    func test_saveEditUpdatesMatchingFindingAndMarksItPending() throws {
        var draft = makeDraft()
        draft.isUploaded = true
        let repository = FindingEditorRepositorySpy()
        let sut = DefaultSaveFindingEditorUseCase(repository: repository)

        try sut.execute(draft: draft, mode: .edit(draft.id))

        XCTAssertEqual(repository.createdDrafts, [])
        XCTAssertEqual(repository.updatedDrafts.count, 1)
        XCTAssertEqual(repository.updatedDrafts.first?.id, draft.id)
        XCTAssertEqual(repository.updatedDrafts.first?.isUploaded, false)
    }

    func test_saveRejectsEditWhenModeAndDraftIDsDiffer() {
        let draft = makeDraft()
        let modeID = UUID()
        let repository = FindingEditorRepositorySpy()
        let sut = DefaultSaveFindingEditorUseCase(repository: repository)

        XCTAssertThrowsError(
            try sut.execute(draft: draft, mode: .edit(modeID))
        ) { error in
            XCTAssertEqual(
                error as? FindingEditorRepositoryError,
                .findingNotFound(modeID)
            )
        }
        XCTAssertEqual(repository.updatedDrafts, [])
    }

    func test_saveRequiresLocation() {
        var draft = makeDraft()
        draft.location = nil

        assertValidationError(.locationRequired, draft: draft)
    }

    func test_saveRequiresTaxonName() {
        var draft = makeDraft()
        draft.taxonName = "  \n "

        assertValidationError(.taxonRequired, draft: draft)
    }

    func test_saveRequiresPositiveTotalCount() {
        var draft = makeDraft()
        draft.totalIndividuals = 0

        assertValidationError(.individualCountRequired, draft: draft)
    }

    func test_saveGenderAcceptsEitherMaleOrFemaleCount() throws {
        var maleDraft = makeDraft()
        maleDraft.individualEntryMode = .gender
        maleDraft.totalIndividuals = 0
        maleDraft.maleIndividuals = 1

        var femaleDraft = makeDraft()
        femaleDraft.individualEntryMode = .gender
        femaleDraft.totalIndividuals = 0
        femaleDraft.femaleIndividuals = 1

        let repository = FindingEditorRepositorySpy()
        let sut = DefaultSaveFindingEditorUseCase(repository: repository)

        try sut.execute(draft: maleDraft, mode: .create)
        try sut.execute(draft: femaleDraft, mode: .create)

        XCTAssertEqual(repository.createdDrafts.count, 2)
    }

    private func assertValidationError(
        _ expectedError: FindingEditorValidationError,
        draft: FindingEditorDraft,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let repository = FindingEditorRepositorySpy()
        let sut = DefaultSaveFindingEditorUseCase(repository: repository)

        XCTAssertThrowsError(
            try sut.execute(draft: draft, mode: .create),
            file: file,
            line: line
        ) { error in
            XCTAssertEqual(
                error as? FindingEditorValidationError,
                expectedError,
                file: file,
                line: line
            )
        }
        XCTAssertEqual(repository.createdDrafts, [], file: file, line: line)
    }

    private func makeDraft(id: UUID = UUID()) -> FindingEditorDraft {
        var draft = FindingEditorDraft.empty(id: id)
        draft.location = FindingEditorLocation(
            latitude: 44.8,
            longitude: 20.4,
            altitude: 120,
            accuracy: 4
        )
        draft.taxonName = "Salamandra salamandra"
        return draft
    }
}

private final class FindingEditorRepositorySpy: FindingEditorRepository {
    var newDraftResult: Result<FindingEditorDraft, Error> = .success(.empty())
    var getDraftResult: Result<FindingEditorDraft, Error> = .success(.empty())
    var createResult: Result<Void, Error> = .success(())
    var updateResult: Result<Void, Error> = .success(())

    private(set) var makeNewDraftCallCount = 0
    private(set) var requestedDraftIDs: [UUID] = []
    private(set) var createdDrafts: [FindingEditorDraft] = []
    private(set) var updatedDrafts: [FindingEditorDraft] = []

    func makeNewDraft() throws -> FindingEditorDraft {
        makeNewDraftCallCount += 1
        return try newDraftResult.get()
    }

    func getDraft(id: UUID) throws -> FindingEditorDraft {
        requestedDraftIDs.append(id)
        return try getDraftResult.get()
    }

    func create(_ draft: FindingEditorDraft) throws {
        createdDrafts.append(draft)
        try createResult.get()
    }

    func update(_ draft: FindingEditorDraft) throws {
        updatedDrafts.append(draft)
        try updateResult.get()
    }
}
