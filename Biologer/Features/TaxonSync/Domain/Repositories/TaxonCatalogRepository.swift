protocol TaxonCatalogRepository {
    func count() throws(TaxonSyncFailure) -> Int

    func upsert(_ entries: [TaxonCatalogEntry]) throws(TaxonSyncFailure)

    func deleteAll() throws(TaxonSyncFailure)
}

protocol InitialTaxonCatalogRepository {
    func loadInitialCatalog(
        scope: TaxonCatalogScope
    ) throws(TaxonSyncFailure) -> InitialTaxonCatalog?
}
