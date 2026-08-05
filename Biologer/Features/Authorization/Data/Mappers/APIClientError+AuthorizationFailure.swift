import Foundation

extension APIClientError {
    var asAuthorizationFailure: AuthorizationFailure {
        let details = failureDetails
        return AuthorizationFailure(
            summary: details.summary,
            message: details.message,
            isInternetConnectionAvailable: details.isInternetConnectionAvailable
        )
    }
}
