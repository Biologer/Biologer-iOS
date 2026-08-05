import Foundation

public struct AuthorizationFailure: Error, Equatable {
    public let summary: String
    public let message: String
    public let isInternetConnectionAvailable: Bool

    public init(
        summary: String = "",
        message: String,
        isInternetConnectionAvailable: Bool = true
    ) {
        self.summary = summary
        self.message = message
        self.isInternetConnectionAvailable = isInternetConnectionAvailable
    }
}
