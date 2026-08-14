struct TaxonSyncCheckpoint: Equatable, Sendable {
    /// Catalog environment to which this resume point belongs.
    let scope: TaxonCatalogScope

    /// The next page to request. A page is advanced only after its Realm write succeeds.
    let nextPage: Int

    /// Fixed page size used by every request in this sync cycle.
    let perPage: Int

    /// Total number of API pages reported for this sync cycle.
    let totalPages: Int

    /// Total number of changed taxa reported for this cycle, not the local database total.
    let totalTaxaCount: Int

    /// Number of taxa safely imported during this sync cycle.
    let importedTaxaCount: Int

    /// The baseline used for every request in this sync cycle.
    let updatedAfter: Int64

    /// The cycle start, used as the next successful-sync timestamp.
    let startedAt: Int64

    /// UI progress reconstructed from the last safely imported page.
    var progress: TaxonSyncProgress {
        TaxonSyncProgress(
            completedPages: max(nextPage - 1, 0),
            totalPages: totalPages,
            importedTaxaCount: importedTaxaCount,
            totalTaxaCount: totalTaxaCount
        )
    }

    /// Indicates whether the persisted values describe a safe and consistent resume point.
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
    /// Catalog environment whose synchronization history is stored here.
    let scope: TaxonCatalogScope

    /// Version timestamp of the bundled CSV baseline after it has been imported.
    var initialCatalogTimestamp: Int64?

    /// Start timestamp of the most recent remote sync that completed successfully.
    var lastSuccessfulSyncTimestamp: Int64?

    /// Persisted resume point for an interrupted or paused remote sync.
    var checkpoint: TaxonSyncCheckpoint?

    /// Best known baseline after which the API should return changed taxa.
    var effectiveUpdatedAfter: Int64 {
        lastSuccessfulSyncTimestamp
            ?? initialCatalogTimestamp
            ?? 0
    }
}
