protocol GetTaxonSyncStateUseCase {
    func execute(scope: TaxonCatalogScope) async -> TaxonSyncState
}

protocol ObserveTaxonSyncStateUseCase {
    func execute(
        scope: TaxonCatalogScope
    ) async -> AsyncStream<TaxonSyncState>
}

protocol CheckTaxonUpdatesUseCase {
    func execute(
        scope: TaxonCatalogScope
    ) async throws(TaxonSyncFailure) -> TaxonSyncCheckResult
}

protocol StartTaxonSyncUseCase {
    func execute(scope: TaxonCatalogScope) async
}

protocol PauseTaxonSyncUseCase {
    func execute(scope: TaxonCatalogScope) async
}

protocol ResumeTaxonSyncUseCase {
    func execute(scope: TaxonCatalogScope) async
}

/// The shared use-case graph consumed by startup, Settings and Taxon Search.
/// Every property is backed by the same TaxonSyncController instance.
struct TaxonSyncUseCases {
    let getState: GetTaxonSyncStateUseCase
    let observeState: ObserveTaxonSyncStateUseCase
    let checkForUpdates: CheckTaxonUpdatesUseCase
    let start: StartTaxonSyncUseCase
    let pause: PauseTaxonSyncUseCase
    let resume: ResumeTaxonSyncUseCase
}
