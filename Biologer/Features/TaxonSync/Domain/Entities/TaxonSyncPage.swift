struct TaxonSyncPageRequest: Equatable, Sendable {
    let page: Int
    let perPage: Int
    let updatedAfter: Int64
}

struct TaxonSyncPage: Equatable, Sendable {
    let entries: [TaxonCatalogEntry]
    let currentPage: Int
    let lastPage: Int
    let totalEntries: Int

    var isLastPage: Bool {
        currentPage >= lastPage
    }

    var nextPage: Int? {
        isLastPage ? nil : currentPage + 1
    }
}
