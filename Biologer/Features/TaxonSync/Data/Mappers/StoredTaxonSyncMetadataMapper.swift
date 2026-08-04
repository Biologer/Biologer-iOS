enum StoredTaxonSyncMetadataMapper {
    static func makeStoredMetadata(
        from metadata: TaxonSyncMetadata
    ) -> StoredTaxonSyncMetadata {
        StoredTaxonSyncMetadata(
            initialCatalogTimestamp: metadata.initialCatalogTimestamp,
            lastSuccessfulSyncTimestamp: metadata.lastSuccessfulSyncTimestamp,
            checkpoint: metadata.checkpoint.map {
                StoredTaxonSyncMetadata.Checkpoint(
                    nextPage: $0.nextPage,
                    perPage: $0.perPage,
                    totalPages: $0.totalPages,
                    totalTaxaCount: $0.totalTaxaCount,
                    importedTaxaCount: $0.importedTaxaCount,
                    updatedAfter: $0.updatedAfter,
                    startedAt: $0.startedAt
                )
            }
        )
    }

    static func makeDomainMetadata(
        from metadata: StoredTaxonSyncMetadata,
        scope: TaxonCatalogScope
    ) -> TaxonSyncMetadata {
        TaxonSyncMetadata(
            scope: scope,
            initialCatalogTimestamp: metadata.initialCatalogTimestamp,
            lastSuccessfulSyncTimestamp: metadata.lastSuccessfulSyncTimestamp,
            checkpoint: metadata.checkpoint.map {
                TaxonSyncCheckpoint(
                    scope: scope,
                    nextPage: $0.nextPage,
                    perPage: $0.perPage,
                    totalPages: $0.totalPages,
                    totalTaxaCount: $0.totalTaxaCount,
                    importedTaxaCount: $0.importedTaxaCount,
                    updatedAfter: $0.updatedAfter,
                    startedAt: $0.startedAt
                )
            }
        )
    }
}
