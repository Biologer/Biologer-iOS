protocol TaxonCatalogRepository {
    func count(scope: TaxonCatalogScope) throws -> Int
    func upsert(
        _ entries: [TaxonCatalogEntry],
        scope: TaxonCatalogScope
    ) throws
    func deleteAll(scope: TaxonCatalogScope) throws
}

protocol TaxonCatalogSeedRepository {
    func loadSeed(
        scope: TaxonCatalogScope
    ) throws -> TaxonCatalogSeed?
}
