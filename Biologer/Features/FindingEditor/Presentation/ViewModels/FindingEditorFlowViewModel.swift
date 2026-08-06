import Foundation

@MainActor
final class FindingEditorFlowViewModel: ObservableObject {
    let editorViewModel: FindingEditorViewModel
    let taxonSearchViewModel: FindingTaxonSearchViewModel
    let taxonSyncViewModel: TaxonSyncViewModel

    init(
        editorViewModel: FindingEditorViewModel,
        taxonSearchViewModel: FindingTaxonSearchViewModel,
        taxonSyncViewModel: TaxonSyncViewModel
    ) {
        self.editorViewModel = editorViewModel
        self.taxonSearchViewModel = taxonSearchViewModel
        self.taxonSyncViewModel = taxonSyncViewModel
    }
}
