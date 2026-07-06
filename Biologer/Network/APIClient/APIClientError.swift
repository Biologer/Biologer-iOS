import Foundation

enum APIClientError: LocalizedError, Equatable {
    case invalidBaseURL
    case invalidURL
    case invalidResponse
    case badRequest(APIErrorPayload?)
    case unauthorized(APIErrorPayload?)
    case forbidden(APIErrorPayload?)
    case notFound(APIErrorPayload?)
    case validationFailed(APIErrorPayload?)
    case serverError(statusCode: Int, response: APIErrorPayload?)
    case decodingFailed(String)
    case requestFailed(message: String, code: Int?)
    case missingMockResponse(String)

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL:
            return "Invalid base URL."
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid server response."
        case .badRequest(let response):
            return response?.displayMessage ?? "Invalid request."
        case .unauthorized(let response):
            return response?.displayMessage ?? "Unauthorized request."
        case .forbidden(let response):
            return response?.displayMessage ?? "Request forbidden."
        case .notFound(let response):
            return response?.displayMessage ?? "Resource not found."
        case .validationFailed(let response):
            return response?.displayMessage ?? "Validation failed."
        case .serverError(let statusCode, let response):
            return response?.displayMessage ?? "Server error with status code: \(statusCode)."
        case .decodingFailed(let message):
            return "Decoding failed: \(message)"
        case .requestFailed(let message, _):
            return message
        case .missingMockResponse(let endpoint):
            return "No mock response configured for \(endpoint)."
        }
    }
}
