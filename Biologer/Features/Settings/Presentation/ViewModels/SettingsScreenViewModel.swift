import Foundation

enum SettingsResetAlert: Identifiable {
    case confirmation
    case noDownloadedTaxa
    case completed

    var id: Int {
        switch self {
        case .confirmation:
            0
        case .noDownloadedTaxa:
            1
        case .completed:
            2
        }
    }
}

final class SettingsScreenViewModel: ObservableObject {
    @Published private(set) var preferences: SettingsPreferences
    @Published var resetAlert: SettingsResetAlert?

    private let preferencesUseCase: SettingsPreferencesUseCase
    private let taxonDataUseCase: SettingsTaxonDataUseCase

    init(
        preferencesUseCase: SettingsPreferencesUseCase,
        taxonDataUseCase: SettingsTaxonDataUseCase
    ) {
        self.preferencesUseCase = preferencesUseCase
        self.taxonDataUseCase = taxonDataUseCase
        preferences = preferencesUseCase.preferences()
    }

    func reload() {
        preferences = preferencesUseCase.preferences()
    }

    func setEnglishNamesEnabled(_ isEnabled: Bool) {
        preferencesUseCase.set(isEnabled, for: .englishNames)
        preferences.alwaysUseEnglishNames = isEnabled
    }

    func setAdultByDefaultEnabled(_ isEnabled: Bool) {
        preferencesUseCase.set(isEnabled, for: .adultByDefault)
        preferences.defaultsToAdult = isEnabled
    }

    func requestTaxaReset() {
        resetAlert = taxonDataUseCase.hasDownloadedTaxa()
            ? .confirmation
            : .noDownloadedTaxa
    }

    func confirmTaxaReset() {
        taxonDataUseCase.resetDownloadedTaxa()
        resetAlert = .completed
    }
}
