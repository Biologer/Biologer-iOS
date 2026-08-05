import Foundation

struct SettingsDataFailure: LocalizedError, Equatable {
    let message: String

    var errorDescription: String? { message }
}
