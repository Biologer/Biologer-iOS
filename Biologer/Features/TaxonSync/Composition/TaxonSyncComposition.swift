/// Shared dependencies and ViewModel construction for every TaxonSync entry point.
struct TaxonSyncComposition {
    let service: TaxonSyncService
    let scopeProvider: TaxonCatalogScopeProviding

    @MainActor
    func makeViewModel() -> TaxonSyncViewModel {
        TaxonSyncViewModel(
            service: service,
            scopeProvider: scopeProvider
        )
    }
}
