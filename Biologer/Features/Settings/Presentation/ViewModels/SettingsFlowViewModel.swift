import Foundation

@MainActor
final class SettingsFlowViewModel: ObservableObject {
    let settingsViewModel: SettingsScreenViewModel
    let projectNameViewModel: ProjectNameSettingsViewModel
    let dataLicenseViewModel: LicenseSettingsViewModel
    let imageLicenseViewModel: LicenseSettingsViewModel
    let automaticDownloadViewModel: AutomaticDownloadSettingsViewModel
    let taxonSyncViewModel: TaxonSyncViewModel
    let aboutViewModel: SettingsAboutViewModel
    let accountViewModel: SettingsAccountViewModel

    init(
        settingsViewModel: SettingsScreenViewModel,
        projectNameViewModel: ProjectNameSettingsViewModel,
        dataLicenseViewModel: LicenseSettingsViewModel,
        imageLicenseViewModel: LicenseSettingsViewModel,
        automaticDownloadViewModel: AutomaticDownloadSettingsViewModel,
        taxonSyncViewModel: TaxonSyncViewModel,
        aboutViewModel: SettingsAboutViewModel,
        accountViewModel: SettingsAccountViewModel
    ) {
        self.settingsViewModel = settingsViewModel
        self.projectNameViewModel = projectNameViewModel
        self.dataLicenseViewModel = dataLicenseViewModel
        self.imageLicenseViewModel = imageLicenseViewModel
        self.automaticDownloadViewModel = automaticDownloadViewModel
        self.taxonSyncViewModel = taxonSyncViewModel
        self.aboutViewModel = aboutViewModel
        self.accountViewModel = accountViewModel
    }

    func licenseViewModel(
        for kind: LicenseKind
    ) -> LicenseSettingsViewModel {
        switch kind {
        case .data:
            dataLicenseViewModel
        case .image:
            imageLicenseViewModel
        }
    }
}
