protocol SettingsLicenseUseCase {
    func options(for kind: LicenseKind) -> [LicenseOption]
    func selectedOption(for kind: LicenseKind) -> LicenseOption
    func select(_ option: LicenseOption, for kind: LicenseKind)
}

final class DefaultSettingsLicenseUseCase: SettingsLicenseUseCase {
    private let repository: SettingsLicenseRepository

    init(repository: SettingsLicenseRepository) {
        self.repository = repository
    }

    func options(for kind: LicenseKind) -> [LicenseOption] {
        repository.options(for: kind)
    }

    func selectedOption(for kind: LicenseKind) -> LicenseOption {
        repository.selectedOption(for: kind)
    }

    func select(_ option: LicenseOption, for kind: LicenseKind) {
        repository.save(option, for: kind)
    }
}
