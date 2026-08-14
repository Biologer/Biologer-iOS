final class StoredSettingsLicenseRepository: SettingsLicenseRepository {
    private let optionsProvider: LicenseOptionsProviding
    private let storage: LicensePreferenceStorage

    init(
        optionsProvider: LicenseOptionsProviding,
        storage: LicensePreferenceStorage
    ) {
        self.optionsProvider = optionsProvider
        self.storage = storage
    }

    func options(for kind: LicenseKind) -> [LicenseOption] {
        optionsProvider.options(for: kind)
    }

    func selectedOption(for kind: LicenseKind) -> LicenseOption {
        let fallback = optionsProvider.defaultOption(for: kind)
        guard let id = storage.selectedLicenseID(for: kind) else {
            return fallback
        }
        return optionsProvider.option(id: id, kind: kind) ?? fallback
    }

    func save(_ option: LicenseOption, for kind: LicenseKind) {
        guard optionsProvider.option(id: option.id, kind: kind) != nil else {
            return
        }
        storage.saveSelectedLicenseID(option.id, for: kind)
    }
}
