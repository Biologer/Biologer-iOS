protocol SettingsPreferencesRepository {
    func load() -> SettingsPreferences
    func save(_ preferences: SettingsPreferences)
}
