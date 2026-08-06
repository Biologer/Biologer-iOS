import Foundation

@MainActor
final class FindingEditorBuilder {
    private let useCases: FindingEditorUseCases
    private let taxonSyncComposition: TaxonSyncComposition

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
        let flowViewModel = FindingEditorFlowViewModel(
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

        return FindingEditorFlow(
            viewModel: flowViewModel,
            locationUseCases: useCases.location,
            onSaved: onSaved
        )
    }
}
