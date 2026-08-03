final class StoredSettingsLicenseRepository: SettingsLicenseRepository {
    private let dataLicenseStorage: LicenseStorage
    private let imageLicenseStorage: LicenseStorage

    init(
        dataLicenseStorage: LicenseStorage,
        imageLicenseStorage: LicenseStorage
    ) {
        self.dataLicenseStorage = dataLicenseStorage
        self.imageLicenseStorage = imageLicenseStorage
    }

    func options(for kind: SettingsLicenseKind) -> [SettingsLicenseOption] {
        storedOptions(for: kind).map(map)
    }

    func selectedOption(for kind: SettingsLicenseKind) -> SettingsLicenseOption {
        let storage = storage(for: kind)
        let fallback = storedOptions(for: kind)[0]
        return map(storage.getLicense() ?? fallback)
    }

    func save(_ option: SettingsLicenseOption, for kind: SettingsLicenseKind) {
        guard var storedOption = storedOptions(for: kind).first(where: { $0.id == option.id }) else {
            return
        }
        storedOption.changeIsSelected(value: true)
        storage(for: kind).saveLicense(license: storedOption)
    }

    private func storedOptions(for kind: SettingsLicenseKind) -> [CheckMarkItem] {
        switch kind {
        case .data:
            CheckMarkItemMapper.getDataLicense()
        case .image:
            CheckMarkItemMapper.getImageLicense()
        }
    }

    private func storage(for kind: SettingsLicenseKind) -> LicenseStorage {
        switch kind {
        case .data:
            dataLicenseStorage
        case .image:
            imageLicenseStorage
        }
    }

    private func map(_ item: CheckMarkItem) -> SettingsLicenseOption {
        SettingsLicenseOption(
            id: item.id,
            title: item.title,
            details: item.placeholder
        )
    }
}
