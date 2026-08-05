import Foundation

struct APIErrorPayload: Decodable, Equatable {
    let message: String?
    let error: String?
    let errorDescription: String?
    let status: String?
    let errors: [String: [String]]?

    var displayMessage: String? {
        message ?? errorDescription ?? error
    }

    enum CodingKeys: String, CodingKey {
        case message
        case error
        case errorDescription = "error_description"
        case status
        case errors
    }
}
