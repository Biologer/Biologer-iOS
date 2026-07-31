import Foundation

enum RegistrationLicenseKind: Equatable {
    case data
    case image
}

struct RegistrationLicensePreference: Equatable {
    let id: Int
    let kind: RegistrationLicenseKind
}
