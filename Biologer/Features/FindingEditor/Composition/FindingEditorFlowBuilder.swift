import Foundation

protocol FindingEditorFlowBuilding {
    @MainActor
    func makeFlow(
        mode: FindingEditorMode,
        onSaved: @escaping (UUID) -> Void,
        onUnsavedChangesChanged: @escaping (Bool) -> Void
    ) -> FindingEditorFlow
}

final class FindingEditorFlowBuilder: FindingEditorFlowBuilding {
    private let useCases: FindingEditorUseCases
    private let taxonSyncComposition: TaxonSyncComposition

    var locationUseCases: FindingLocationUseCases {
        useCases.location
    }

    init(
        useCases: FindingEditorUseCases,
        taxonSyncComposition: TaxonSyncComposition
    ) {
        self.useCases = useCases
        self.taxonSyncComposition = taxonSyncComposition
    }

    @MainActor
    func makeFlow(
        mode: FindingEditorMode,
        onSaved: @escaping (UUID) -> Void,
        onUnsavedChangesChanged: @escaping (Bool) -> Void
    ) -> FindingEditorFlow {
        FindingEditorFlow(
            mode: mode,
            flowBuilder: self,
            onSaved: onSaved,
            onUnsavedChangesChanged: onUnsavedChangesChanged
        )
    }

    @MainActor
    func makeViewModel(
        mode: FindingEditorMode,
        onUnsavedChangesChanged: @escaping (Bool) -> Void
    ) -> FindingEditorFlowViewModel {
        FindingEditorFlowViewModel(
            editorViewModel: FindingEditorViewModel(
                mode: mode,
                loadFinding: useCases.loadFinding,
                saveFinding: useCases.saveFinding,
                onUnsavedChangesChanged: onUnsavedChangesChanged
            ),
            taxonSearchViewModel: FindingTaxonSearchViewModel(
                searchTaxa: useCases.searchTaxa
            ),
            taxonSyncViewModel: taxonSyncComposition.makeViewModel()
        )
    }
}
