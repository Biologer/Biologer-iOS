import Foundation

protocol SettingsPreferencesUseCase {
    func preferences() -> SettingsPreferences
    func set(_ isEnabled: Bool, for toggle: SettingsToggle)
    func saveProjectName(_ projectName: String)
    func selectAutomaticTaxonDownload(_ option: AutomaticTaxonDownload)
}

final class DefaultSettingsPreferencesUseCase: SettingsPreferencesUseCase {
    private let repository: SettingsPreferencesRepository

    init(repository: SettingsPreferencesRepository) {
        self.repository = repository
    }

    func preferences() -> SettingsPreferences {
        repository.load()
    }

    func set(_ isEnabled: Bool, for toggle: SettingsToggle) {
        var preferences = repository.load()
        switch toggle {
        case .englishNames:
            preferences.alwaysUseEnglishNames = isEnabled
        case .adultByDefault:
            preferences.defaultsToAdult = isEnabled
        }
        repository.save(preferences)
    }

    func saveProjectName(_ projectName: String) {
        var preferences = repository.load()
        preferences.projectName = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        repository.save(preferences)
    }

    func selectAutomaticTaxonDownload(_ option: AutomaticTaxonDownload) {
        var preferences = repository.load()
        preferences.automaticTaxonDownload = option
        repository.save(preferences)
    }
}
