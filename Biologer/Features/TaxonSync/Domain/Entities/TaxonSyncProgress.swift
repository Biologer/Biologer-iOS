struct TaxonSyncProgress: Equatable, Sendable {
    /// Number of pages whose entries and checkpoint were safely persisted.
    let completedPages: Int

    /// Total number of pages reported for the current sync cycle.
    let totalPages: Int

    /// Number of changed taxa imported during the current sync cycle.
    let importedTaxaCount: Int

    /// Total number of changed taxa reported for the current sync cycle.
    let totalTaxaCount: Int

    /// Normalized progress in the `0...1` range, preferring taxon counts over page counts.
    var fractionCompleted: Double {
        let fraction: Double

        if totalTaxaCount > 0 {
            fraction = Double(importedTaxaCount) / Double(totalTaxaCount)
        } else if totalPages > 0 {
            fraction = Double(completedPages) / Double(totalPages)
        } else {
            return 0
        }

        return min(max(fraction, 0), 1)
    }
}
