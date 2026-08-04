protocol TaxonSyncMetadataRepository {
    func loadMetadata(
        scope: TaxonCatalogScope
    ) throws -> TaxonSyncMetadata

    func saveMetadata(_ metadata: TaxonSyncMetadata) throws
    func clearMetadata(scope: TaxonCatalogScope) throws
}
