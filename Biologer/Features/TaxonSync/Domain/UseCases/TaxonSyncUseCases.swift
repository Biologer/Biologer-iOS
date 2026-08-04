protocol GetTaxonSyncStateUseCase {
    func execute(scope: TaxonCatalogScope) async -> TaxonSyncState
}

protocol ObserveTaxonSyncStateUseCase {
    func execute(
        scope: TaxonCatalogScope
    ) -> AsyncStream<TaxonSyncState>
}

protocol CheckTaxonUpdatesUseCase {
    func execute(
        scope: TaxonCatalogScope
    ) async throws -> TaxonSyncCheckResult
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
