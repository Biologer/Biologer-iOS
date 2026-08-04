protocol TaxonUpdatesRepository {
    func fetchPage(
        scope: TaxonCatalogScope,
        request: TaxonSyncPageRequest
    ) async throws(TaxonSyncFailure) -> TaxonSyncPage
}
