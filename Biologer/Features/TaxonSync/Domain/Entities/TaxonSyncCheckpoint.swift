struct TaxonSyncCheckpoint: Equatable, Sendable {
    let scope: TaxonCatalogScope
    /// The next page to request. A page is advanced only after its Realm write succeeds.
    let nextPage: Int
    let perPage: Int
    let totalPages: Int
    let totalTaxaCount: Int
    let importedTaxaCount: Int
    /// The baseline used for every request in this sync cycle.
    let updatedAfter: Int64
    /// The cycle start, used as the next successful-sync timestamp.
    let startedAt: Int64

    var progress: TaxonSyncProgress {
        TaxonSyncProgress(
            completedPages: max(nextPage - 1, 0),
            totalPages: totalPages,
            importedTaxaCount: importedTaxaCount,
            totalTaxaCount: totalTaxaCount
        )
    }

    var isValid: Bool {
        nextPage > 0
            && perPage > 0
            && totalPages > 0
            && nextPage <= totalPages
            && totalTaxaCount > 0
            && importedTaxaCount >= 0
            && importedTaxaCount <= totalTaxaCount
    }
}

struct TaxonSyncMetadata: Equatable, Sendable {
    let scope: TaxonCatalogScope
    var initialCatalogTimestamp: Int64?
    var lastSuccessfulSyncTimestamp: Int64?
    var checkpoint: TaxonSyncCheckpoint?

    var effectiveUpdatedAfter: Int64 {
        lastSuccessfulSyncTimestamp
            ?? initialCatalogTimestamp
            ?? 0
    }
}
