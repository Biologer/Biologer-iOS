import Foundation

final class APIClient: APIClientProtocol {
    private let session: URLSession
    private let requestBuilder: URLRequestBuilder
    private let responseValidator: APIResponseValidating
    private let responseDecoder: APIResponseDecoding

    init(
        session: URLSession = .shared,
        responseValidator: APIResponseValidating = APIResponseValidator(),
        responseDecoder: APIResponseDecoding = APIResponseDecoder()
    ) {
        self.session = session
        self.requestBuilder = URLRequestBuilder()
        self.responseValidator = responseValidator
        self.responseDecoder = responseDecoder
    }

    init(
        session: URLSession = .shared,
        requestBuilder: URLRequestBuilder,
        responseValidator: APIResponseValidating = APIResponseValidator(),
        responseDecoder: APIResponseDecoding = APIResponseDecoder()
    ) {
        self.session = session
        self.requestBuilder = requestBuilder
        self.responseValidator = responseValidator
        self.responseDecoder = responseDecoder
    }

    func send<E: APIEndpoint>(_ endpoint: E) async throws -> E.Response {
        do {
            let request = try requestBuilder.buildRequest(from: endpoint)
            let (data, response) = try await session.data(for: request)

            try responseValidator.validate(response: response, data: data)

            return try responseDecoder.decode(E.Response.self, from: data)
        } catch let error as APIClientError {
            throw error
        } catch {
            let nsError = error as NSError
            throw APIClientError.requestFailed(message: error.localizedDescription, code: nsError.code)
        }
    }
}
