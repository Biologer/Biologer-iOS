struct TaxonSyncPageRequest: Equatable, Sendable {
    /// One-based page number requested from the updates API.
    let page: Int

    /// Maximum number of changed taxa requested per page.
    let perPage: Int

    /// Stable timestamp baseline used to filter changes throughout the whole cycle.
    let updatedAfter: Int64
}

struct TaxonSyncPage: Equatable, Sendable {
    /// Changed taxon records returned on this API page.
    let entries: [TaxonCatalogEntry]

    /// One-based page number reported by the API response.
    let currentPage: Int

    /// Last page number reported for this sync cycle.
    let lastPage: Int

    /// Total number of matching changes across all pages, not the local database total.
    let totalEntries: Int

    /// Indicates whether this response is the final page of the cycle.
    var isLastPage: Bool {
        currentPage >= lastPage
    }

    /// Next page to request, or `nil` when the current page is the final one.
    var nextPage: Int? {
        isLastPage ? nil : currentPage + 1
    }
}
