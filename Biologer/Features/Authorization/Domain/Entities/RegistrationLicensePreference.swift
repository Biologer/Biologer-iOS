import Foundation

struct RegistrationLicensePreference: Equatable {
    /// Backend identifier of the license selected during registration.
    let id: Int

    /// Resource category to which the selected license applies.
    let kind: LicenseKind
}
