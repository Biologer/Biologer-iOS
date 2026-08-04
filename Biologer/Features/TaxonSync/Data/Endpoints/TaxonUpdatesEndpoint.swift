import Foundation

struct TaxonUpdatesEndpoint: APIEndpoint {
    typealias Response = TaxonUpdatesResponse

    let host: String
    let path = APIConstants.taxonPath
    let request: TaxonSyncPageRequest

    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(
                name: "page",
                value: String(request.page)
            ),
            URLQueryItem(
                name: "per_page",
                value: String(request.perPage)
            ),
            URLQueryItem(
                name: APIConstants.updatedAfter,
                value: String(request.updatedAfter)
            )
        ]
    }
}
