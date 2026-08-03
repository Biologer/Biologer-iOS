import SwiftUI
import UIKit

final class SettingsBuilder {
    private let settingsStorage: SettingsStorage
    private let dataLicenseStorage: LicenseStorage
    private let imageLicenseStorage: LicenseStorage
    private let taxonPaginationStorage: TaxonsPaginationInfoStorage
    private let environmentStorage: EnvironmentStorage
    private let userStorage: UserStorage

    init(
        settingsStorage: SettingsStorage,
        dataLicenseStorage: LicenseStorage,
        imageLicenseStorage: LicenseStorage,
        taxonPaginationStorage: TaxonsPaginationInfoStorage,
        environmentStorage: EnvironmentStorage,
        userStorage: UserStorage
    ) {
        self.settingsStorage = settingsStorage
        self.dataLicenseStorage = dataLicenseStorage
        self.imageLicenseStorage = imageLicenseStorage
        self.taxonPaginationStorage = taxonPaginationStorage
        self.environmentStorage = environmentStorage
        self.userStorage = userStorage
    }

    func makeViewController(
        onDownloadTaxa: @escaping Observer<Void>,
        onLogout: @escaping Observer<Void>,
        onDeleteAccount: @escaping Observer<Bool>
    ) -> UIViewController {
        let environment = currentEnvironment()
        let flow = SettingsFlow(
            useCases: makeUseCases(),
            accountContextProvider: { [weak self] in
                SettingsAccountContext(
                    email: self?.userStorage.getUser()?.email ?? "",
                    username: self?.userStorage.getUser()?.fullName ?? "",
                    environment: self?.currentEnvironment() ?? environment
                )
            },
            appVersion: currentAppVersion(),
            onOpenURL: { urlString in
                guard let url = URL(string: urlString) else { return }
                UIApplication.shared.open(url)
            },
            onDownloadTaxa: onDownloadTaxa,
            onLogout: onLogout,
            onDeleteAccount: onDeleteAccount
        )
        return UIHostingController(rootView: flow)
    }

    private func makeUseCases() -> SettingsUseCases {
        SettingsUseCases(
            preferences: DefaultSettingsPreferencesUseCase(
                repository: StoredSettingsPreferencesRepository(storage: settingsStorage)
            ),
            licenses: DefaultSettingsLicenseUseCase(
                repository: StoredSettingsLicenseRepository(
                    dataLicenseStorage: dataLicenseStorage,
                    imageLicenseStorage: imageLicenseStorage
                )
            ),
            taxonData: DefaultSettingsTaxonDataUseCase(
                repository: RealmDownloadedTaxaRepository(
                    paginationStorage: taxonPaginationStorage
                )
            )
        )
    }

    private func currentEnvironment() -> String {
        guard let environment = environmentStorage.getEnvironment() else {
            return ""
        }
        return "https://\(environment.host)"
    }

    private func currentAppVersion() -> String {
        guard
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        else {
            return ""
        }
        return "\("AboutBiologer.lb.appVersion".localized) \(version) (\(build))"
    }
}
