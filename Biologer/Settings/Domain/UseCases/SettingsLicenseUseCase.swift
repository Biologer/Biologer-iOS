protocol SettingsLicenseUseCase {
    func options(for kind: SettingsLicenseKind) -> [SettingsLicenseOption]
    func selectedOption(for kind: SettingsLicenseKind) -> SettingsLicenseOption
    func select(_ option: SettingsLicenseOption, for kind: SettingsLicenseKind)
}

final class DefaultSettingsLicenseUseCase: SettingsLicenseUseCase {
    private let repository: SettingsLicenseRepository

    init(repository: SettingsLicenseRepository) {
        self.repository = repository
    }

    func options(for kind: SettingsLicenseKind) -> [SettingsLicenseOption] {
        repository.options(for: kind)
    }

    func selectedOption(for kind: SettingsLicenseKind) -> SettingsLicenseOption {
        repository.selectedOption(for: kind)
    }

    func select(_ option: SettingsLicenseOption, for kind: SettingsLicenseKind) {
        repository.save(option, for: kind)
    }
}
