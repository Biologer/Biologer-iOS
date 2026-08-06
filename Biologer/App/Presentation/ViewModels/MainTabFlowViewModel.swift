import Foundation

enum MainTab: Hashable {
    case findings
    case editor
    case settings
}

@MainActor
final class MainTabFlowViewModel: ObservableObject {
    @Published var selectedTab: MainTab = .findings
    @Published private(set) var editorMode: FindingEditorMode = .create
    @Published private(set) var editorSessionID = UUID()
    @Published private(set) var pendingEditorMode: FindingEditorMode?

    private let findingsFlowController: FindingsFlowControlling
    private var editorHasUnsavedChanges = false

    init(findingsFlowController: FindingsFlowControlling) {
        self.findingsFlowController = findingsFlowController
    }

    func openCreateEditor() {
        requestEditor(mode: .create)
    }

    func openEditEditor(id: UUID) {
        requestEditor(mode: .edit(id))
    }

    func updateEditorUnsavedChanges(_ hasUnsavedChanges: Bool) {
        editorHasUnsavedChanges = hasUnsavedChanges
    }

    func didSaveFinding() {
        editorHasUnsavedChanges = false
        pendingEditorMode = nil
        findingsFlowController.showListAndReload()
        replaceEditor(mode: .create)
        selectedTab = .findings
    }

    func continueEditing() {
        pendingEditorMode = nil
    }

    func discardChangesAndOpenPendingEditor() {
        guard let pendingEditorMode else { return }
        self.pendingEditorMode = nil
        replaceEditor(mode: pendingEditorMode)
    }

    private func requestEditor(mode: FindingEditorMode) {
        selectedTab = .editor

        guard editorMode != mode else { return }
        guard editorHasUnsavedChanges else {
            replaceEditor(mode: mode)
            return
        }

        pendingEditorMode = mode
    }

    private func replaceEditor(mode: FindingEditorMode) {
        editorHasUnsavedChanges = false
        editorMode = mode
        editorSessionID = UUID()
    }
}
