import XCTest
@testable import Biologer

@MainActor
final class FindingEditorViewModelTests: XCTestCase {
    func test_loadPublishesDraftContent() {
        let expectedDraft = makeDraft()
        let context = makeSUT(draft: expectedDraft)

        context.sut.load()

        XCTAssertEqual(context.sut.draft, expectedDraft)
        XCTAssertEqual(context.sut.loadState, .content)
    }

    func test_load_whenContentIsAlreadyLoaded_doesNotLoadAgain() {
        let context = makeSUT(draft: makeDraft())

        context.sut.load()
        context.sut.load()

        XCTAssertEqual(context.loadFinding.callCount, 1)
    }

    func test_saveWaitsForSuccessConfirmationBeforeCompletingCreate() {
        let draft = makeDraft()
        let context = makeSUT(
            draft: draft,
            mode: .create
        )
        context.sut.load()

        context.sut.save()

        XCTAssertEqual(context.saveFinding.receivedDrafts, [draft])
        XCTAssertEqual(
            context.sut.alert?.kind,
            .saveSuccess(isEditing: false)
        )

        let savedID = context.sut.confirmAlert(
            FindingEditorAlert(kind: .saveSuccess(isEditing: false))
        )

        XCTAssertEqual(savedID, draft.id)
        XCTAssertNil(context.sut.alert)
    }

    func test_saveReportsUpdateSuccessForEditMode() {
        let draft = makeDraft()
        let context = makeSUT(draft: draft, mode: .edit(draft.id))
        context.sut.load()

        context.sut.save()

        XCTAssertEqual(
            context.sut.alert?.kind,
            .saveSuccess(isEditing: true)
        )
    }

    func test_savePublishesValidationFailureWithoutCompleting() {
        let draft = makeDraft()
        let context = makeSUT(draft: draft)
        context.saveFinding.result = .failure(
            FindingEditorValidationError.taxonRequired
        )
        context.sut.load()

        context.sut.save()

        XCTAssertEqual(
            context.sut.alert?.kind,
            .validation(.taxonRequired)
        )
        XCTAssertNil(
            context.sut.confirmAlert(
                FindingEditorAlert(kind: .validation(.taxonRequired))
            )
        )
    }

    func test_presentationActionsReturnCurrentData() {
        let draft = makeDraft()
        let context = makeSUT(draft: draft)
        context.sut.load()

        let canAddPhoto = context.sut.canAddPhoto()
        let photoPresentation = context.sut.photoPresentation(at: 0)

        XCTAssertTrue(canAddPhoto)
        XCTAssertEqual(photoPresentation?.0, draft.photos)
        XCTAssertEqual(photoPresentation?.1, 0)
    }

    func test_photoLimitPreventsFourthPhotoRequest() {
        var draft = makeDraft()
        draft.photos = (0..<3).map {
            FindingEditorPhoto(
                name: "\($0).jpg",
                imageData: Data([UInt8($0)]),
                remoteURL: nil
            )
        }
        let context = makeSUT(draft: draft)
        context.sut.load()

        let canAddPhoto = context.sut.canAddPhoto()

        XCTAssertFalse(canAddPhoto)
        XCTAssertEqual(context.sut.alert?.kind, .photoLimit)
    }

    func test_selectingTaxonUpdatesNameAndClearsPreviousDependentOptions() {
        var draft = makeDraft()
        draft.atlasCode = FindingEditorOption(id: 1, name: "Old atlas")
        draft.developmentStage = FindingEditorOption(id: 2, name: "Old stage")
        let context = makeSUT(draft: draft)
        context.sut.load()
        let selectedTaxon = FindingEditorTaxon(
            apiID: 42,
            name: "Alcedo atthis",
            usesAtlasCodes: true,
            developmentStages: [],
            translations: []
        )

        context.sut.selectTaxon(selectedTaxon)

        XCTAssertEqual(context.sut.draft.taxon, selectedTaxon)
        XCTAssertEqual(context.sut.draft.taxonName, selectedTaxon.name)
        XCTAssertNil(context.sut.draft.atlasCode)
        XCTAssertNil(context.sut.draft.developmentStage)
    }

    func test_editingLoadedDraftPublishesUnsavedChanges() {
        let draft = makeDraft()
        var receivedStates: [Bool] = []
        let context = makeSUT(
            draft: draft,
            onUnsavedChangesChanged: { receivedStates.append($0) }
        )
        context.sut.load()

        context.sut.draft.comment = "Updated field note"

        XCTAssertTrue(context.sut.hasUnsavedChanges)
        XCTAssertEqual(receivedStates, [true])
    }

    func test_successfulSaveClearsUnsavedChanges() {
        let draft = makeDraft()
        var receivedStates: [Bool] = []
        let context = makeSUT(
            draft: draft,
            onUnsavedChangesChanged: { receivedStates.append($0) }
        )
        context.sut.load()
        context.sut.draft.comment = "Updated field note"

        context.sut.save()

        XCTAssertFalse(context.sut.hasUnsavedChanges)
        XCTAssertEqual(receivedStates, [true, false])
    }

    private func makeSUT(
        draft: FindingEditorDraft,
        mode: FindingEditorMode = .create,
        onUnsavedChangesChanged: @escaping (Bool) -> Void = { _ in }
    ) -> FindingEditorViewModelTestContext {
        let loadFinding = FindingEditorLoadUseCaseStub(draft: draft)
        let saveFinding = FindingEditorSaveUseCaseSpy()
        let sut = FindingEditorViewModel(
            mode: mode,
            loadFinding: loadFinding,
            saveFinding: saveFinding,
            onUnsavedChangesChanged: onUnsavedChangesChanged
        )
        return FindingEditorViewModelTestContext(
            sut: sut,
            loadFinding: loadFinding,
            saveFinding: saveFinding
        )
    }

    private func makeDraft() -> FindingEditorDraft {
        var draft = FindingEditorDraft.empty()
        draft.location = FindingEditorLocation(
            latitude: 44.8,
            longitude: 20.4,
            altitude: 120,
            accuracy: 4
        )
        draft.taxonName = "Salamandra salamandra"
        draft.photos = [
            FindingEditorPhoto(
                name: "photo.jpg",
                imageData: Data([1]),
                remoteURL: nil
            )
        ]
        return draft
    }
}

@MainActor
private struct FindingEditorViewModelTestContext {
    let sut: FindingEditorViewModel
    let loadFinding: FindingEditorLoadUseCaseStub
    let saveFinding: FindingEditorSaveUseCaseSpy
}

private final class FindingEditorLoadUseCaseStub: LoadFindingEditorUseCase {
    let draft: FindingEditorDraft
    private(set) var callCount = 0

    init(draft: FindingEditorDraft) {
        self.draft = draft
    }

    func execute(mode: FindingEditorMode) throws -> FindingEditorDraft {
        callCount += 1
        return draft
    }
}

private final class FindingEditorSaveUseCaseSpy: SaveFindingEditorUseCase {
    var result: Result<UUID, Error>?
    private(set) var receivedDrafts: [FindingEditorDraft] = []
    private(set) var receivedModes: [FindingEditorMode] = []

    func execute(
        draft: FindingEditorDraft,
        mode: FindingEditorMode
    ) throws -> UUID {
        receivedDrafts.append(draft)
        receivedModes.append(mode)
        return try result?.get() ?? draft.id
    }
}
