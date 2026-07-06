import Foundation

extension APIClientError {
    func asAPIError() -> APIError {
        switch self {
        case .requestFailed(let message, let code):
            if let code, NoInternetConnectionValidator.noInternetConnection(errorCode: code) {
                return APIError(
                    title: ErrorConstant.noInternetConnectionTitle,
                    description: ErrorConstant.noInternetConnectionDescription,
                    isInternetConnectionAvailable: false
                )
            }

            return APIError(description: message)
        case .badRequest(let payload),
             .unauthorized(let payload),
             .forbidden(let payload),
             .notFound(let payload),
             .validationFailed(let payload),
             .serverError(_, let payload):
            return APIError(
                title: payload?.title ?? "",
                description: payload?.description ?? ErrorConstant.parsingErrorConstant
            )
        case .decodingFailed:
            return APIError(description: ErrorConstant.parsingErrorConstant)
        default:
            return APIError(description: localizedDescription)
        }
    }
}

private extension APIErrorPayload {
    var title: String? {
        error ?? message
    }

    var description: String? {
        firstFieldError ?? errorDescription ?? displayMessage
    }

    var firstFieldError: String? {
        errors?.values.first?.first
    }
}
