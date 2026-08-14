protocol SettingsLicenseRepository {
    func options(for kind: LicenseKind) -> [LicenseOption]
    func selectedOption(for kind: LicenseKind) -> LicenseOption
    func save(_ option: LicenseOption, for kind: LicenseKind)
}
