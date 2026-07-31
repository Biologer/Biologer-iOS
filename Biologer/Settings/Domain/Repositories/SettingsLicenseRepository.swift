protocol SettingsLicenseRepository {
    func options(for kind: SettingsLicenseKind) -> [SettingsLicenseOption]
    func selectedOption(for kind: SettingsLicenseKind) -> SettingsLicenseOption
    func save(_ option: SettingsLicenseOption, for kind: SettingsLicenseKind)
}
