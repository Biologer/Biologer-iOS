import Foundation

struct TaxonEndpoint: APIEndpoint {
    typealias Response = TaxonDataResponse

    let host: String
    let path = APIConstants.taxonPath
    let queryItems: [URLQueryItem]

    init(host: String, currentPage: Int, perPage: Int, updatedAfter: Int64) {
        self.host = host
        self.queryItems = [
            URLQueryItem(name: "page", value: String(currentPage)),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "updated_after", value: String(updatedAfter))
        ]
    }
}
