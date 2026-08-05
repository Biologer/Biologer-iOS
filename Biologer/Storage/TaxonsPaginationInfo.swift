import Foundation

public final class TaxonsPaginationInfo: Codable {
    public let currentPage: Int
    public let perPage: Int
    public let lastPage: Int
    public let total: Int

    public var isAllTaxonDownloaded: Bool {
        currentPage == lastPage
    }

    init(
        currentPage: Int,
        perPage: Int = APIConstants.taxonsPerPage,
        lastPage: Int,
        total: Int
    ) {
        self.currentPage = currentPage
        self.perPage = perPage
        self.lastPage = lastPage
        self.total = total
    }
}
