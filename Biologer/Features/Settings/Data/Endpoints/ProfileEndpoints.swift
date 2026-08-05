import Foundation

struct GetProfileEndpoint: APIEndpoint {
    typealias Response = UserDataResponse

    let host: String
    let path = APIConstants.myProfilePath
}

struct DeleteAccountEndpoint: APIEndpoint {
    typealias Response = EmptyAPIResponse

    let host: String
    let path: String
    let queryItems: [URLQueryItem]
    let method: APIHTTPMethod = .delete

    init(host: String, userID: Int, deleteObservations: Bool) {
        self.host = host
        self.path = "\(APIConstants.deleteUserPath)/\(userID)"
        self.queryItems = [
            URLQueryItem(
                name: "delete_observations",
                value: deleteObservations ? "1" : "0"
            )
        ]
    }
}
