struct SettingsPreferences: Equatable {
    var alwaysUseEnglishNames: Bool
    var defaultsToAdult: Bool
    var projectName: String
    var automaticTaxonDownload: AutomaticTaxonDownload
}

enum SettingsToggle {
    case englishNames
    case adultByDefault
}

enum AutomaticTaxonDownload: String, CaseIterable, Identifiable {
    case onlyWiFi
    case onAnyNetwork
    case alwaysAskUser

    var id: String {
        rawValue
    }
}
