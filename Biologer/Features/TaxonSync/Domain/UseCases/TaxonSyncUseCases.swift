// Each use case is intentionally a narrow adapter over the same app-scoped controller.
// View models receive only the operation they need instead of the whole orchestrator.
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
