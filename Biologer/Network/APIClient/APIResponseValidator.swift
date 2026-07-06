import Foundation

protocol APIResponseValidating {
    func validate(response: URLResponse, data: Data) throws
}

final class APIResponseValidator: APIResponseValidating {
    private let decoder: JSONDecoder

    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        guard !(200...299).contains(httpResponse.statusCode) else {
            return
        }

        let errorResponse = try? decoder.decode(APIErrorPayload.self, from: data)

        switch httpResponse.statusCode {
        case 400:
            throw APIClientError.badRequest(errorResponse)
        case 401:
            throw APIClientError.unauthorized(errorResponse)
        case 403:
            throw APIClientError.forbidden(errorResponse)
        case 404:
            throw APIClientError.notFound(errorResponse)
        case 422:
            throw APIClientError.validationFailed(errorResponse)
        default:
            throw APIClientError.serverError(
                statusCode: httpResponse.statusCode,
                response: errorResponse
            )
        }
    }
}
