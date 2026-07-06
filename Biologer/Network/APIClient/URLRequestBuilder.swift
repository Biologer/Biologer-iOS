import Foundation

struct URLRequestBuilder {
    private let environment: APIEnvironment
    private let bodyEncoder: JSONEncoder

    init(
        environment: APIEnvironment,
        bodyEncoder: JSONEncoder = JSONEncoder()
    ) {
        self.environment = environment
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
        guard !environment.scheme.isEmpty, !environment.host.isEmpty else {
            throw APIClientError.invalidBaseURL
        }

        var components = URLComponents()
        components.scheme = environment.scheme
        components.host = environment.host
        components.path = joinedPath(prefix: environment.pathPrefix, path: endpoint.path)

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
