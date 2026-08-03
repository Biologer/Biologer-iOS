import Foundation

protocol FindingEditorRepository {
    func makeNewDraft() throws -> FindingEditorDraft
    func getDraft(id: UUID) throws -> FindingEditorDraft
    func create(_ draft: FindingEditorDraft) throws
    func update(_ draft: FindingEditorDraft) throws
}

enum FindingEditorRepositoryError: Error, Equatable {
    case findingNotFound(UUID)
}
