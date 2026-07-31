import Foundation

final class AutomaticDownloadSettingsViewModel: ObservableObject {
    let options = AutomaticTaxonDownload.allCases
    @Published private(set) var selectedOption: AutomaticTaxonDownload

    private let useCase: SettingsPreferencesUseCase

    init(useCase: SettingsPreferencesUseCase) {
        self.useCase = useCase
        selectedOption = useCase.preferences().automaticTaxonDownload
    }

    func select(_ option: AutomaticTaxonDownload) {
        useCase.selectAutomaticTaxonDownload(option)
        selectedOption = option
    }

    func title(for option: AutomaticTaxonDownload) -> String {
        switch option {
        case .onlyWiFi:
            "DownloadAndUpload.nav.onlyWifi".localized
        case .onAnyNetwork:
            "DownloadAndUpload.nav.onAnyNetwork".localized
        case .alwaysAskUser:
            "DownloadAndUpload.nav.alwaysAsk".localized
        }
    }
}
