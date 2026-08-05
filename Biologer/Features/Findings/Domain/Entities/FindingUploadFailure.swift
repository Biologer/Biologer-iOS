import Foundation

struct FindingUploadFailure: LocalizedError, Equatable {
    let message: String

    var errorDescription: String? { message }
}
