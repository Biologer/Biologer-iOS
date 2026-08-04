struct TaxonSyncPageValidator {
    func validate(
        _ page: TaxonSyncPage,
        expectedPage: Int
    ) throws(TaxonSyncFailure) {
        guard page.currentPage == expectedPage,
              page.totalEntries >= 0 else {
            throw .invalidResponse
        }

        if page.totalEntries == 0 {
            guard page.entries.isEmpty else {
                throw .invalidResponse
            }
            return
        }

        guard page.lastPage >= page.currentPage,
              !page.entries.isEmpty,
              page.totalEntries >= page.entries.count else {
            throw .invalidResponse
        }
    }
}
