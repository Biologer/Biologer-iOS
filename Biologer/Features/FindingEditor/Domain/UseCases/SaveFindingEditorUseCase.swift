import Foundation

protocol SaveFindingEditorUseCase {
    @discardableResult
    func execute(
        draft: FindingEditorDraft,
        mode: FindingEditorMode
    ) throws -> UUID
}

enum FindingEditorValidationError: Error, Equatable {
    case locationRequired
    case taxonRequired
    case individualCountRequired
}

final class DefaultSaveFindingEditorUseCase: SaveFindingEditorUseCase {
    private let repository: FindingEditorRepository

    init(repository: FindingEditorRepository) {
        self.repository = repository
    }

    @discardableResult
    func execute(
        draft: FindingEditorDraft,
        mode: FindingEditorMode
    ) throws -> UUID {
        try validate(draft)

        var draftToSave = draft
        draftToSave.isUploaded = false

        switch mode {
        case .create:
            try repository.create(draftToSave)
        case .edit(let id):
            guard id == draftToSave.id else {
                throw FindingEditorRepositoryError.findingNotFound(id)
            }
            try repository.update(draftToSave)
        }

        return draftToSave.id
    }

    private func validate(_ draft: FindingEditorDraft) throws {
        guard draft.location != nil else {
            throw FindingEditorValidationError.locationRequired
        }
        guard !draft.taxonName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw FindingEditorValidationError.taxonRequired
        }

        switch draft.individualEntryMode {
        case .total:
            guard draft.totalIndividuals > 0 else {
                throw FindingEditorValidationError.individualCountRequired
            }
        case .gender:
            guard draft.maleIndividuals + draft.femaleIndividuals > 0 else {
                throw FindingEditorValidationError.individualCountRequired
            }
        }
    }
}
