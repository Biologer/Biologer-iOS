import Foundation

protocol SetupUseCase {
    func currentSettings() -> Settings
    func toggleSetting(for type: SetupItemType)
    func projectName() -> String
    func saveProjectName(_ name: String)
    func autoDownloadItems() -> [SetupRadioAndTitleModel]
    func selectAutoDownloadTaxon(_ type: SetupRadioAndTitleModelType)
    func dataLicenses() -> [CheckMarkItem]
    func selectedDataLicense() -> CheckMarkItem
    func saveDataLicense(_ license: CheckMarkItem)
    func imageLicenses() -> [CheckMarkItem]
    func selectedImageLicense() -> CheckMarkItem
    func saveImageLicense(_ license: CheckMarkItem)
    func hasDownloadedTaxa() -> Bool
    func resetDownloadedTaxa()
}

protocol SetupTaxonLocalDataStore {
    func hasTaxa() -> Bool
    func deleteTaxa()
}

final class DefaultSetupUseCase: SetupUseCase {
    private let settingsStorage: SettingsStorage
    private let dataLicenseStorage: LicenseStorage
    private let imageLicenseStorage: LicenseStorage
    private let taxonPaginationStorage: TaxonsPaginationInfoStorage
    private let taxonLocalDataStore: SetupTaxonLocalDataStore

    init(
        settingsStorage: SettingsStorage,
        dataLicenseStorage: LicenseStorage,
        imageLicenseStorage: LicenseStorage,
        taxonPaginationStorage: TaxonsPaginationInfoStorage,
        taxonLocalDataStore: SetupTaxonLocalDataStore
    ) {
        self.settingsStorage = settingsStorage
        self.dataLicenseStorage = dataLicenseStorage
        self.imageLicenseStorage = imageLicenseStorage
        self.taxonPaginationStorage = taxonPaginationStorage
        self.taxonLocalDataStore = taxonLocalDataStore
    }

    func currentSettings() -> Settings {
        guard let settings = settingsStorage.getSettings() else {
            let settings = Settings()
            settingsStorage.saveSettings(settings: settings)
            return settings
        }
        return settings
    }

    func toggleSetting(for type: SetupItemType) {
        let settings = currentSettings()

        switch type {
        case .chooseGropups:
            settings.toggleChooseSpecisGroup()
        case .englishNames:
            settings.toggleAlwaysEnglishName()
        case .adultByDefault:
            settings.toggleSetAdultByDefault()
        case .observationEntry:
            settings.toggleAdvanceObservationEntry()
        case .projectName, .imageLicense, .dataLicense, .downloadAllTaxa, .downloadUpload, .resetAllTaxa:
            return
        }

        settingsStorage.saveSettings(settings: settings)
    }

    func projectName() -> String {
        currentSettings().projectName
    }

    func saveProjectName(_ name: String) {
        let settings = currentSettings()
        settings.setProjectName(name: name)
        settingsStorage.saveSettings(settings: settings)
    }

    func autoDownloadItems() -> [SetupRadioAndTitleModel] {
        SetupDownloadAndUploadMapper.getItems(settings: currentSettings())
    }

    func selectAutoDownloadTaxon(_ type: SetupRadioAndTitleModelType) {
        let settings = currentSettings()
        settings.setAutoDownloadTaxonBy(type: type)
        settingsStorage.saveSettings(settings: settings)
    }

    func dataLicenses() -> [CheckMarkItem] {
        CheckMarkItemMapper.getDataLicense()
    }

    func selectedDataLicense() -> CheckMarkItem {
        dataLicenseStorage.getLicense() ?? dataLicenses()[0]
    }

    func saveDataLicense(_ license: CheckMarkItem) {
        dataLicenseStorage.saveLicense(license: license)
    }

    func imageLicenses() -> [CheckMarkItem] {
        CheckMarkItemMapper.getImageLicense()
    }

    func selectedImageLicense() -> CheckMarkItem {
        imageLicenseStorage.getLicense() ?? imageLicenses()[0]
    }

    func saveImageLicense(_ license: CheckMarkItem) {
        imageLicenseStorage.saveLicense(license: license)
    }

    func hasDownloadedTaxa() -> Bool {
        taxonLocalDataStore.hasTaxa()
    }

    func resetDownloadedTaxa() {
        taxonLocalDataStore.deleteTaxa()
        taxonPaginationStorage.delete()
    }
}

final class SettingsStorageSetupUseCase: SetupUseCase {
    private let settingsStorage: SettingsStorage

    init(settingsStorage: SettingsStorage) {
        self.settingsStorage = settingsStorage
    }

    func currentSettings() -> Settings {
        settingsStorage.getSettings() ?? Settings()
    }

    func toggleSetting(for type: SetupItemType) {
        guard let settings = settingsStorage.getSettings() else { return }

        switch type {
        case .chooseGropups:
            settings.toggleChooseSpecisGroup()
        case .englishNames:
            settings.toggleAlwaysEnglishName()
        case .adultByDefault:
            settings.toggleSetAdultByDefault()
        case .observationEntry:
            settings.toggleAdvanceObservationEntry()
        case .projectName, .imageLicense, .dataLicense, .downloadAllTaxa, .downloadUpload, .resetAllTaxa:
            return
        }

        settingsStorage.saveSettings(settings: settings)
    }

    func projectName() -> String {
        currentSettings().projectName
    }

    func saveProjectName(_ name: String) {
        let settings = currentSettings()
        settings.setProjectName(name: name)
        settingsStorage.saveSettings(settings: settings)
    }

    func autoDownloadItems() -> [SetupRadioAndTitleModel] {
        SetupDownloadAndUploadMapper.getItems(settings: currentSettings())
    }

    func selectAutoDownloadTaxon(_ type: SetupRadioAndTitleModelType) {
        let settings = currentSettings()
        settings.setAutoDownloadTaxonBy(type: type)
        settingsStorage.saveSettings(settings: settings)
    }

    func dataLicenses() -> [CheckMarkItem] {
        CheckMarkItemMapper.getDataLicense()
    }

    func selectedDataLicense() -> CheckMarkItem {
        dataLicenses()[0]
    }

    func saveDataLicense(_ license: CheckMarkItem) {}

    func imageLicenses() -> [CheckMarkItem] {
        CheckMarkItemMapper.getImageLicense()
    }

    func selectedImageLicense() -> CheckMarkItem {
        imageLicenses()[0]
    }

    func saveImageLicense(_ license: CheckMarkItem) {}

    func hasDownloadedTaxa() -> Bool {
        false
    }

    func resetDownloadedTaxa() {}
}
