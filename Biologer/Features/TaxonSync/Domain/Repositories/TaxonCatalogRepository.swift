protocol TaxonCatalogRepository {
    func count(scope: TaxonCatalogScope) throws -> Int
    func upsert(
        _ entries: [TaxonCatalogEntry],
        scope: TaxonCatalogScope
    ) throws
    func deleteAll(scope: TaxonCatalogScope) throws
}

protocol InitialTaxonCatalogRepository {
    func loadInitialCatalog(
        scope: TaxonCatalogScope
    ) throws(TaxonSyncFailure) -> InitialTaxonCatalog?
}
