import Foundation

struct ObservationTypesEndpoint: APIEndpoint {
    typealias Response = ObservationDataResponse

    let host: String
    let path = APIConstants.observationTypesPath
    let queryItems: [URLQueryItem]

    init(host: String, updatedAfter: Int) {
        self.host = host
        self.queryItems = [
            URLQueryItem(
                name: APIConstants.updatedAfter,
                value: String(updatedAfter)
            )
        ]
    }
}
