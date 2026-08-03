import XCTest
@testable import Biologer

@MainActor
final class FindingEditorV2ViewModelTests: XCTestCase {
    func test_loadPublishesDraftContent() {
        let expectedDraft = makeDraft()
        let context = makeSUT(draft: expectedDraft)

        context.sut.load()

        XCTAssertEqual(context.sut.draft, expectedDraft)
        XCTAssertEqual(context.sut.loadState, .content)
    }

    func test_saveWaitsForSuccessConfirmationBeforeCompletingCreate() {
        let draft = makeDraft()
        var savedIDs: [UUID] = []
        let context = makeSUT(
            draft: draft,
            mode: .create,
            onSaved: { savedIDs.append($0) }
        )
        context.sut.load()

        context.sut.save()

        XCTAssertEqual(context.saveFinding.receivedDrafts, [draft])
        XCTAssertEqual(savedIDs, [])
        XCTAssertEqual(
            context.sut.alert?.kind,
            .saveSuccess(isEditing: false)
        )

        context.sut.confirmAlert(
            FindingEditorAlert(kind: .saveSuccess(isEditing: false))
        )

        XCTAssertEqual(savedIDs, [draft.id])
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
        var completionCount = 0
        let context = makeSUT(
            draft: draft,
            onSaved: { _ in completionCount += 1 }
        )
        context.saveFinding.result = .failure(
            FindingEditorValidationError.taxonRequired
        )
        context.sut.load()

        context.sut.save()

        XCTAssertEqual(
            context.sut.alert?.kind,
            .validation(.taxonRequired)
        )
        XCTAssertEqual(completionCount, 0)
    }

    func test_navigationActionsForwardCurrentData() {
        let draft = makeDraft()
        var location: FindingEditorLocation?
        var taxonSearchCallCount = 0
        var photoSource: FindingEditorPhotoSource?
        var shownPhotoIndex: Int?
        let context = makeSUT(
            draft: draft,
            onSelectLocation: { location = $0 },
            onSelectTaxon: { taxonSearchCallCount += 1 },
            onAddPhoto: { photoSource = $0 },
            onShowPhotos: { _, index in shownPhotoIndex = index }
        )
        context.sut.load()

        context.sut.requestLocationSelection()
        context.sut.requestTaxonSelection()
        context.sut.requestPhoto(from: .photoLibrary)
        context.sut.showPhoto(at: 0)

        XCTAssertEqual(location, draft.location)
        XCTAssertEqual(taxonSearchCallCount, 1)
        XCTAssertEqual(photoSource, .photoLibrary)
        XCTAssertEqual(shownPhotoIndex, 0)
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
        var requestCount = 0
        let context = makeSUT(
            draft: draft,
            onAddPhoto: { _ in requestCount += 1 }
        )
        context.sut.load()

        context.sut.requestPhoto(from: .camera)

        XCTAssertEqual(requestCount, 0)
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
        onSaved: @escaping (UUID) -> Void = { _ in },
        onSelectLocation: @escaping (FindingEditorLocation?) -> Void = { _ in },
        onSelectTaxon: @escaping () -> Void = {},
        onAddPhoto: @escaping (FindingEditorPhotoSource) -> Void = { _ in },
        onShowPhotos: @escaping ([FindingEditorPhoto], Int) -> Void = { _, _ in },
        onUnsavedChangesChanged: @escaping (Bool) -> Void = { _ in }
    ) -> FindingEditorViewModelTestContext {
        let loadFinding = FindingEditorLoadUseCaseStub(draft: draft)
        let saveFinding = FindingEditorSaveUseCaseSpy()
        let sut = FindingEditorV2ViewModel(
            mode: mode,
            loadFinding: loadFinding,
            saveFinding: saveFinding,
            onSaved: onSaved,
            onSelectLocation: onSelectLocation,
            onSelectTaxon: onSelectTaxon,
            onAddPhoto: onAddPhoto,
            onShowPhotos: onShowPhotos,
            onUnsavedChangesChanged: onUnsavedChangesChanged
        )
        return FindingEditorViewModelTestContext(
            sut: sut,
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
    let sut: FindingEditorV2ViewModel
    let saveFinding: FindingEditorSaveUseCaseSpy
}

private final class FindingEditorLoadUseCaseStub: LoadFindingEditorUseCase {
    let draft: FindingEditorDraft

    init(draft: FindingEditorDraft) {
        self.draft = draft
    }

    func execute(mode: FindingEditorMode) throws -> FindingEditorDraft {
        draft
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
