protocol LoadFindingEditorUseCase {
    func execute(mode: FindingEditorMode) throws -> FindingEditorDraft
}

final class DefaultLoadFindingEditorUseCase: LoadFindingEditorUseCase {
    private let repository: FindingEditorRepository

    init(repository: FindingEditorRepository) {
        self.repository = repository
    }

    func execute(mode: FindingEditorMode) throws -> FindingEditorDraft {
        switch mode {
        case .create:
            try repository.makeNewDraft()
        case .edit(let id):
            try repository.getDraft(id: id)
        }
    }
}
