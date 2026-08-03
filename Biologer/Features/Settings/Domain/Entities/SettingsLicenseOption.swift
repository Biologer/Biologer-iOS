enum SettingsLicenseKind: Hashable {
    case data
    case image
}

struct SettingsLicenseOption: Equatable, Identifiable {
    let id: Int
    let title: String
    let details: String
}
