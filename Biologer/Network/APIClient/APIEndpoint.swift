import Foundation

public protocol APIEndpoint {
    associatedtype Response: Decodable

    var host: String { get }
    var path: String { get }
    var method: APIHTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var body: APIRequestBody { get }
}

public extension APIEndpoint {
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
