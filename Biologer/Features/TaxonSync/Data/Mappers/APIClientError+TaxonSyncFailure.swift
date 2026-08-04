import Foundation

extension APIClientError {
    var asTaxonSyncFailure: TaxonSyncFailure {
        switch self {
        case .requestFailed(_, let code):
            if let code,
               NoInternetConnectionValidator.noInternetConnection(errorCode: code) {
                return .networkUnavailable
            }

            return .unknown
        case .unauthorized:
            return .unauthorized
        case .invalidBaseURL,
             .invalidURL,
             .invalidResponse,
             .decodingFailed:
            return .invalidResponse
        default:
            return .unknown
        }
    }
}
