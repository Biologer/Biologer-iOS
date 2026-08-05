import Foundation

struct URLRequestBuilder {
    private let scheme: String
    private let pathPrefix: String
    private let bodyEncoder: JSONEncoder

    init(
        scheme: String = "https",
        pathPrefix: String = "",
        bodyEncoder: JSONEncoder = JSONEncoder()
    ) {
        self.scheme = scheme
        self.pathPrefix = pathPrefix
        self.bodyEncoder = bodyEncoder
    }

    func buildRequest<E: APIEndpoint>(from endpoint: E) throws -> URLRequest {
        let url = try buildURL(from: endpoint)

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        endpoint.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let bodyData = try endpoint.body.data(using: bodyEncoder) {
            request.httpBody = bodyData

            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue(APIConstants.applicationJson, forHTTPHeaderField: "Content-Type")
            }
        }

        return request
    }

    private func buildURL<E: APIEndpoint>(from endpoint: E) throws -> URL {
        guard !scheme.isEmpty, !endpoint.host.isEmpty else {
            throw APIClientError.invalidBaseURL
        }

        var components = URLComponents()
        components.scheme = scheme
        components.host = endpoint.host
        components.path = joinedPath(prefix: pathPrefix, path: endpoint.path)

        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }

        guard let url = components.url else {
            throw APIClientError.invalidURL
        }

        return url
    }

    private func joinedPath(prefix: String, path: String) -> String {
        let segments = [prefix, path]
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "/")) }
            .filter { !$0.isEmpty }

        return "/" + segments.joined(separator: "/")
    }
}
