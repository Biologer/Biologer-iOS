enum LicenseKind: String, Codable, Hashable, Sendable {
    /// License applied to observation data.
    case data

    /// License applied to uploaded photographs.
    case image
}

/// Stable license identity plus fresh presentation text from the current app locale.
struct LicenseOption: Identifiable, Equatable, Sendable {
    /// Backend license identifier persisted as the user's choice.
    let id: Int

    /// Resource category to which this license applies.
    let kind: LicenseKind

    /// Localized license name shown to the user.
    let title: String

    /// Localized explanation shown below the license name.
    let details: String
}
