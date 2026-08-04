protocol TaxonSyncMetadataRepository {
    func loadMetadata(
        scope: TaxonCatalogScope
    ) throws(TaxonSyncFailure) -> TaxonSyncMetadata

    func saveMetadata(
        _ metadata: TaxonSyncMetadata
    ) throws(TaxonSyncFailure)

    func clearMetadata(
        scope: TaxonCatalogScope
    ) throws(TaxonSyncFailure)
}
