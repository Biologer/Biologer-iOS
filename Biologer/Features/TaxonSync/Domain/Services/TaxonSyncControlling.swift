/// Application-level sync contract shared by the individual use-case adapters.
/// The concrete implementation is an actor so only one sync cycle can mutate its state.
protocol TaxonSyncControlling: AnyObject {
    func state(
        scope: TaxonCatalogScope
    ) async -> TaxonSyncState

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
