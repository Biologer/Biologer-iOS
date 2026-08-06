import Foundation

@MainActor
protocol FindingEditorFlowBuilding {
    func makeFlow(
        mode: FindingEditorMode,
        onSaved: @escaping Observer<UUID>,
        onUnsavedChangesChanged: @escaping Observer<Bool>
    ) -> FindingEditorFlow
}

@MainActor
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

    func makeFlow(
        mode: FindingEditorMode,
        onSaved: @escaping Observer<UUID>,
        onUnsavedChangesChanged: @escaping Observer<Bool>
    ) -> FindingEditorFlow {
        FindingEditorFlow(
            mode: mode,
            flowBuilder: self,
            onSaved: onSaved,
            onUnsavedChangesChanged: onUnsavedChangesChanged
        )
    }

    func makeViewModel(
        mode: FindingEditorMode,
        onUnsavedChangesChanged: @escaping Observer<Bool>
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
            taxonSyncViewModel: TaxonSyncViewModel(
                useCases: taxonSyncComposition.useCases,
                scopeProvider: taxonSyncComposition.scopeProvider
            )
        )
    }
}
