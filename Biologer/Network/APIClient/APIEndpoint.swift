import Foundation

protocol APIEndpoint {
    associatedtype Response: Decodable

    var path: String { get }
    var method: APIHTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var body: APIRequestBody { get }
}

extension APIEndpoint {
    var method: APIHTTPMethod { .get }
    var queryItems: [URLQueryItem] { [] }
    var body: APIRequestBody { .empty }

    var headers: [String: String] {
        [
            "Accept": APIConstants.applicationJson,
            "User-Agent": APIConstants.userAgentName
        ]
    }
}
