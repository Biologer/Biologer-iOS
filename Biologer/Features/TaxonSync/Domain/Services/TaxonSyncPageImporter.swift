struct TaxonSyncPageImportResult {
    let metadata: TaxonSyncMetadata
    let importedTaxaCount: Int

    var checkpoint: TaxonSyncCheckpoint? {
        metadata.checkpoint
    }

    var isComplete: Bool {
        checkpoint == nil
    }
}

/// Applies one API page atomically from the feature's point of view:
/// Realm is updated first and metadata/checkpoint is saved afterwards.
/// Repeating a page after a crash is therefore safe because Realm performs an upsert.
final class TaxonSyncPageImporter {
    private let catalogRepository: TaxonCatalogRepository
    private let metadataRepository: TaxonSyncMetadataRepository

    init(
        catalogRepository: TaxonCatalogRepository,
        metadataRepository: TaxonSyncMetadataRepository
    ) {
        self.catalogRepository = catalogRepository
        self.metadataRepository = metadataRepository
    }

    func importPage(
        _ page: TaxonSyncPage,
        scope: TaxonCatalogScope,
        metadata initialMetadata: TaxonSyncMetadata,
        previouslyImportedTaxaCount: Int,
        pageSize: Int,
        updatedAfter: Int64,
        startedAt: Int64
    ) throws(TaxonSyncFailure) -> TaxonSyncPageImportResult {
        try catalogRepository.upsert(page.entries)

        var metadata = initialMetadata
        let importedTaxaCount = previouslyImportedTaxaCount
            + page.entries.count

        if page.isLastPage {
            metadata.lastSuccessfulSyncTimestamp = startedAt
            metadata.checkpoint = nil
        } else {
            metadata.checkpoint = TaxonSyncCheckpoint(
                scope: scope,
                nextPage: page.currentPage + 1,
                perPage: pageSize,
                totalPages: page.lastPage,
                totalTaxaCount: page.totalEntries,
                importedTaxaCount: importedTaxaCount,
                updatedAfter: updatedAfter,
                startedAt: startedAt
            )
        }

        try metadataRepository.saveMetadata(metadata)
        return TaxonSyncPageImportResult(
            metadata: metadata,
            importedTaxaCount: importedTaxaCount
        )
    }

    func complete(
        metadata initialMetadata: TaxonSyncMetadata,
        startedAt: Int64
    ) throws(TaxonSyncFailure) -> TaxonSyncMetadata {
        var metadata = initialMetadata
        metadata.lastSuccessfulSyncTimestamp = startedAt
        metadata.checkpoint = nil
        try metadataRepository.saveMetadata(metadata)
        return metadata
    }
}
