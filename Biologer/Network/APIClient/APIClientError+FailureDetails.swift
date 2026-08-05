import Foundation

struct APIClientFailureDetails: Equatable {
    let summary: String
    let message: String
    let isInternetConnectionAvailable: Bool
}

extension APIClientError {
    var failureDetails: APIClientFailureDetails {
        switch self {
        case .requestFailed(let message, let code):
            if let code,
               NoInternetConnectionValidator.noInternetConnection(errorCode: code) {
                return APIClientFailureDetails(
                    summary: "API.lb.noInternetError".localized,
                    message: "API.lb.noInternetDescriptionError".localized,
                    isInternetConnectionAvailable: false
                )
            }

            return defaultFailureDetails(message: message)
        case .badRequest(let payload),
             .unauthorized(let payload),
             .forbidden(let payload),
             .notFound(let payload),
             .validationFailed(let payload),
             .serverError(_, let payload):
            return APIClientFailureDetails(
                summary: payload?.summary ?? "",
                message: payload?.details ?? "API.lb.parsingError".localized,
                isInternetConnectionAvailable: true
            )
        case .decodingFailed:
            return defaultFailureDetails(
                message: "API.lb.parsingError".localized
            )
        default:
            return defaultFailureDetails(message: localizedDescription)
        }
    }

    private func defaultFailureDetails(message: String) -> APIClientFailureDetails {
        APIClientFailureDetails(
            summary: "API.lb.error".localized,
            message: message,
            isInternetConnectionAvailable: true
        )
    }
}

private extension APIErrorPayload {
    var summary: String? {
        error ?? message
    }

    var details: String? {
        firstFieldError ?? errorDescription ?? displayMessage
    }

    var firstFieldError: String? {
        errors?.values.first?.first
    }
}
