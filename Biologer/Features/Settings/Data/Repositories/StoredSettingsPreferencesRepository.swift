final class StoredSettingsPreferencesRepository: SettingsPreferencesRepository {
    private let storage: SettingsStorage

    init(storage: SettingsStorage) {
        self.storage = storage
    }

    func load() -> SettingsPreferences {
        let settings = loadStoredSettings()
        return SettingsPreferences(
            alwaysUseEnglishNames: settings.alwaysEnglishName,
            defaultsToAdult: settings.setAdultByDefault,
            projectName: settings.projectName,
            automaticTaxonDownload: map(settings.selectedAutoDownloadTaxon.type)
        )
    }

    func save(_ preferences: SettingsPreferences) {
        let settings = loadStoredSettings()

        if settings.alwaysEnglishName != preferences.alwaysUseEnglishNames {
            settings.toggleAlwaysEnglishName()
        }
        if settings.setAdultByDefault != preferences.defaultsToAdult {
            settings.toggleSetAdultByDefault()
        }
        settings.setProjectName(name: preferences.projectName)
        settings.setAutoDownloadTaxonBy(type: map(preferences.automaticTaxonDownload))

        storage.saveSettings(settings: settings)
    }

    private func loadStoredSettings() -> Settings {
        guard let settings = storage.getSettings() else {
            let settings = Settings()
            storage.saveSettings(settings: settings)
            return settings
        }
        return settings
    }

    private func map(_ value: AutomaticTaxonDownloadPreference) -> AutomaticTaxonDownload {
        switch value {
        case .onlyWiFi:
            .onlyWiFi
        case .onAnyNetwork:
            .onAnyNetwork
        case .alwaysAskUser:
            .alwaysAskUser
        }
    }

    private func map(_ value: AutomaticTaxonDownload) -> AutomaticTaxonDownloadPreference {
        switch value {
        case .onlyWiFi:
            .onlyWiFi
        case .onAnyNetwork:
            .onAnyNetwork
        case .alwaysAskUser:
            .alwaysAskUser
        }
    }
}
