import Foundation

extension APIError {
    var asAuthorizationFailure: AuthorizationFailure {
        AuthorizationFailure(
            summary: title,
            message: description,
            isInternetConnectionAvailable: isInternetConnectionAvailable
        )
    }
}
