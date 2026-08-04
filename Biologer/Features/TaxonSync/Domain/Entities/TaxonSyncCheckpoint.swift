struct TaxonSyncCheckpoint: Equatable, Sendable {
    let scope: TaxonCatalogScope
    let nextPage: Int
    let perPage: Int
    let totalPages: Int
    let totalTaxaCount: Int
    let importedTaxaCount: Int
    let updatedAfter: Int64

    var progress: TaxonSyncProgress {
        TaxonSyncProgress(
            completedPages: max(nextPage - 1, 0),
            totalPages: totalPages,
            importedTaxaCount: importedTaxaCount,
            totalTaxaCount: totalTaxaCount
        )
    }
}

struct TaxonSyncMetadata: Equatable, Sendable {
    let scope: TaxonCatalogScope
    var seedTimestamp: Int64?
    var lastSuccessfulSyncTimestamp: Int64?
    var checkpoint: TaxonSyncCheckpoint?

    var effectiveUpdatedAfter: Int64 {
        lastSuccessfulSyncTimestamp
            ?? seedTimestamp
            ?? 0
    }
}
