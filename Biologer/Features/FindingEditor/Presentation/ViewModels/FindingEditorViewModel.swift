import Combine
import Foundation

enum FindingEditorLoadState: Equatable {
    case idle
    case loading
    case content
    case failure
}

enum FindingEditorPhotoSource: Equatable {
    case camera
    case photoLibrary
}

struct FindingEditorAlert: Identifiable, Equatable {
    enum Kind: Equatable {
        case validation(FindingEditorValidationError)
        case photoLimit
        case saveFailure
        case saveSuccess(isEditing: Bool)
    }

    let id = UUID()
    let kind: Kind

    static func == (lhs: FindingEditorAlert, rhs: FindingEditorAlert) -> Bool {
        lhs.kind == rhs.kind
    }
}

@MainActor
final class FindingEditorViewModel: ObservableObject {
    @Published var draft = FindingEditorDraft.empty() {
        didSet {
            updateUnsavedChangesState()
        }
    }
    @Published private(set) var loadState: FindingEditorLoadState = .idle
    @Published private(set) var isSaving = false
    @Published private(set) var hasUnsavedChanges = false
    @Published var alert: FindingEditorAlert?

    let mode: FindingEditorMode

    private let loadFinding: LoadFindingEditorUseCase
    private let saveFinding: SaveFindingEditorUseCase
    private let onSaved: (UUID) -> Void
    private let onSelectLocation: (FindingEditorLocation?) -> Void
    private let onSelectTaxon: () -> Void
    private let onAddPhoto: (FindingEditorPhotoSource) -> Void
    private let onShowPhotos: ([FindingEditorPhoto], Int) -> Void
    private let onUnsavedChangesChanged: (Bool) -> Void
    private var didLoad = false
    private var savedFindingID: UUID?
    private var loadedDraft: FindingEditorDraft?

    init(
        mode: FindingEditorMode,
        loadFinding: LoadFindingEditorUseCase,
        saveFinding: SaveFindingEditorUseCase,
        onSaved: @escaping (UUID) -> Void,
        onSelectLocation: @escaping (FindingEditorLocation?) -> Void,
        onSelectTaxon: @escaping () -> Void,
        onAddPhoto: @escaping (FindingEditorPhotoSource) -> Void,
        onShowPhotos: @escaping ([FindingEditorPhoto], Int) -> Void,
        onUnsavedChangesChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.mode = mode
        self.loadFinding = loadFinding
        self.saveFinding = saveFinding
        self.onSaved = onSaved
        self.onSelectLocation = onSelectLocation
        self.onSelectTaxon = onSelectTaxon
        self.onAddPhoto = onAddPhoto
        self.onShowPhotos = onShowPhotos
        self.onUnsavedChangesChanged = onUnsavedChangesChanged
    }

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var isBusy: Bool {
        loadState == .loading || isSaving
    }

    func load() {
        guard !didLoad else { return }
        didLoad = true
        loadState = .loading

        do {
            let loadedDraft = try loadFinding.execute(mode: mode)
            self.loadedDraft = loadedDraft
            draft = loadedDraft
            updateUnsavedChangesState()
            loadState = .content
        } catch {
            loadState = .failure
        }
    }

    func retryLoad() {
        didLoad = false
        load()
    }

    func save() {
        guard !isSaving, loadState == .content else { return }
        isSaving = true
        defer { isSaving = false }

        do {
            let id = try saveFinding.execute(draft: draft, mode: mode)
            savedFindingID = id
            loadedDraft = draft
            updateUnsavedChangesState()
            alert = FindingEditorAlert(kind: .saveSuccess(isEditing: isEditing))
        } catch let error as FindingEditorValidationError {
            alert = FindingEditorAlert(kind: .validation(error))
        } catch {
            alert = FindingEditorAlert(kind: .saveFailure)
        }
    }

    func updateTaxonName(_ name: String) {
        draft.taxonName = name
        guard draft.taxon?.name != name else { return }
        draft.taxon = nil
        draft.atlasCode = nil
        draft.developmentStage = nil
    }

    func updateLocation(_ location: FindingEditorLocation) {
        draft.location = location
    }

    func selectTaxon(_ taxon: FindingEditorTaxon) {
        draft.taxon = taxon
        draft.taxonName = taxon.name
        draft.atlasCode = nil
        draft.developmentStage = nil
    }

    func requestLocationSelection() {
        onSelectLocation(draft.location)
    }

    func requestTaxonSelection() {
        onSelectTaxon()
    }

    func requestPhoto(from source: FindingEditorPhotoSource) {
        guard draft.photos.count < 3 else {
            alert = FindingEditorAlert(kind: .photoLimit)
            return
        }
        onAddPhoto(source)
    }

    func addPhoto(_ photo: FindingEditorPhoto) {
        guard draft.photos.count < 3 else {
            alert = FindingEditorAlert(kind: .photoLimit)
            return
        }
        draft.photos.append(photo)
    }

    func removePhoto(id: UUID) {
        draft.photos.removeAll { $0.id == id }
    }

    func showPhoto(at index: Int) {
        guard draft.photos.indices.contains(index) else { return }
        onShowPhotos(draft.photos, index)
    }

    func toggleObservation(id: Int) {
        guard let index = draft.observations.firstIndex(where: { $0.id == id }) else {
            return
        }
        draft.observations[index].isSelected.toggle()
    }

    func dismissAlert() {
        alert = nil
    }

    func confirmAlert(_ alert: FindingEditorAlert) {
        guard case .saveSuccess = alert.kind else {
            dismissAlert()
            return
        }

        self.alert = nil
        guard let savedFindingID else { return }
        self.savedFindingID = nil
        onSaved(savedFindingID)
    }

    private func updateUnsavedChangesState() {
        let hasUnsavedChanges = loadedDraft.map { draft != $0 } ?? false
        guard hasUnsavedChanges != self.hasUnsavedChanges else { return }

        self.hasUnsavedChanges = hasUnsavedChanges
        onUnsavedChangesChanged(hasUnsavedChanges)
    }
}
