struct TaxonSyncProgress: Equatable, Sendable {
    let completedPages: Int
    let totalPages: Int
    let importedTaxaCount: Int
    let totalTaxaCount: Int

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
