@MainActor
final class TaxonSyncFlowBuilder {
    private let composition: TaxonSyncComposition

    init(composition: TaxonSyncComposition) {
        self.composition = composition
    }

    func makeFlow(
        onContinue: (() -> Void)? = nil
    ) -> TaxonSyncFlow {
        TaxonSyncFlow(
            viewModel: TaxonSyncViewModel(
                useCases: composition.useCases,
                scopeProvider: composition.scopeProvider
            ),
            onContinue: onContinue
        )
    }
}
