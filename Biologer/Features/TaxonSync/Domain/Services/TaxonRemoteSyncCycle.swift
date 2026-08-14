/// First API page retained between `checkForUpdates` and `start`.
/// This is intentionally in memory only; persisted resume information lives in a checkpoint.
struct TaxonSyncPendingUpdate {
    let firstPage: TaxonSyncPage
    let updatedAfter: Int64
    let startedAt: Int64
}

/// Mutable cursor for one remote pagination cycle.
///
/// Keeping the cursor in one value prevents a resumed cycle from accidentally
/// mixing its persisted baseline, page size or timestamp with a new cycle.
struct TaxonRemoteSyncCycle {
    var metadata: TaxonSyncMetadata
    private(set) var nextPage: Int
    private(set) var importedTaxaCount: Int
    let updatedAfter: Int64
    let startedAt: Int64
    private(set) var progress: TaxonSyncProgress?
    let pageSize: Int

    private var cachedPage: TaxonSyncPage?

    /// Restores the exact request cursor saved in the metadata after the last
    /// successful page import. Returns `nil` when no resume point exists.
    init?(resuming metadata: TaxonSyncMetadata) {
        guard let checkpoint = metadata.checkpoint else {
            return nil
        }

        self.metadata = metadata
        self.nextPage = checkpoint.nextPage
        self.importedTaxaCount = checkpoint.importedTaxaCount
        self.updatedAfter = checkpoint.updatedAfter
        self.startedAt = checkpoint.startedAt
        self.progress = checkpoint.progress
        self.pageSize = max(checkpoint.perPage, 1)
        self.cachedPage = nil
    }

    /// Reuses the first page already downloaded by `checkForUpdates`.
    init(
        metadata: TaxonSyncMetadata,
        pendingUpdate: TaxonSyncPendingUpdate,
        pageSize: Int
    ) {
        self.metadata = metadata
        self.nextPage = 1
        self.importedTaxaCount = 0
        self.updatedAfter = pendingUpdate.updatedAfter
        self.startedAt = pendingUpdate.startedAt
        self.progress = nil
        self.pageSize = pageSize
        self.cachedPage = pendingUpdate.firstPage
    }

    /// Starts a new cycle from the latest complete local catalog baseline.
    init(
        metadata: TaxonSyncMetadata,
        pageSize: Int,
        startedAt: Int64
    ) {
        self.metadata = metadata
        self.nextPage = 1
        self.importedTaxaCount = 0
        self.updatedAfter = metadata.effectiveUpdatedAfter
        self.startedAt = startedAt
        self.progress = nil
        self.pageSize = pageSize
        self.cachedPage = nil
    }

    var request: TaxonSyncPageRequest {
        TaxonSyncPageRequest(
            page: nextPage,
            perPage: pageSize,
            updatedAfter: updatedAfter
        )
    }

    mutating func consumeCachedPage() -> TaxonSyncPage? {
        defer {
            cachedPage = nil
        }
        return cachedPage
    }

    /// Advances the in-memory cursor from the checkpoint persisted by PageImporter.
    /// A missing checkpoint means that PageImporter committed the final page.
    mutating func advance(
        after importResult: TaxonSyncPageImportResult
    ) -> Bool {
        metadata = importResult.metadata
        importedTaxaCount = importResult.importedTaxaCount

        guard let checkpoint = importResult.checkpoint else {
            return true
        }

        nextPage = checkpoint.nextPage
        progress = checkpoint.progress
        return false
    }
}
