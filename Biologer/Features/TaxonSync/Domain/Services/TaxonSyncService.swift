protocol TaxonSyncStateProviding: AnyObject {
    func state(
        scope: TaxonCatalogScope
    ) async -> TaxonSyncState
}

/// Full sync contract used by interactive TaxonSync screens.
/// The concrete implementation is an actor so only one sync cycle can mutate its state.
protocol TaxonSyncService: TaxonSyncStateProviding {
    func observe(
        scope: TaxonCatalogScope
    ) async -> AsyncStream<TaxonSyncState>

    func checkForUpdates(
        scope: TaxonCatalogScope
    ) async throws(TaxonSyncFailure) -> TaxonSyncCheckResult

    func start(scope: TaxonCatalogScope) async
    func pause(scope: TaxonCatalogScope) async
    func resume(scope: TaxonCatalogScope) async
}
