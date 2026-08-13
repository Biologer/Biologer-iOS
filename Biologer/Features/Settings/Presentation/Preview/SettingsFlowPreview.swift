import SwiftUI

struct SettingsFlow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            makeSettingsFlow()
                .previewDisplayName("Settings ")

            makeSettingsFlow()
                .preferredColorScheme(.dark)
                .previewDisplayName("Settings  - Dark")
        }
    }

    static func makeSettingsFlow(
        onDownloadTaxa: @escaping () -> Void = {}
    ) -> SettingsFlow {
        let preferencesRepository = PreviewSettingsPreferencesRepository()
        let licenseRepository = PreviewSettingsLicenseRepository()
        let taxonDataRepository = PreviewDownloadedTaxaRepository()
        let useCases = SettingsUseCases(
            preferences: DefaultSettingsPreferencesUseCase(
                repository: preferencesRepository
            ),
            licenses: DefaultSettingsLicenseUseCase(
                repository: licenseRepository
            ),
            taxonData: DefaultSettingsTaxonDataUseCase(
                repository: taxonDataRepository
            )
        )

        return SettingsFlowBuilder(
            useCases: useCases,
            accountContextProvider: {
                SettingsAccountContext(
                    email: "field.biologist@example.com",
                    username: "Nikola Popovic",
                    environment: "https://dev.biologer.org"
                )
            },
            appVersion: "Version: 3.0.4 (Preview)",
            accountUseCase: PreviewUserAccountUseCase(),
            logoutUseCase: PreviewLogoutUseCase(),
            taxonSyncComposition: TaxonSyncPreviewFactory.makeComposition(
                state: .idle(.init(
                    scope: .init(environmentHost: "api.biologer.org"),
                    availability: .ready,
                    localTaxaCount: 1240,
                    lastSuccessfulSyncTimestamp: nil
                ))
            )
        ).makeFlow(onDownloadTaxa: onDownloadTaxa)
    }
}

private final class PreviewUserAccountUseCase: UserAccountUseCase {
    func loadCurrentUser() async throws(SettingsDataFailure) -> User {
        User(
            id: 1,
            firstName: "Nikola",
            lastName: "Popovic",
            email: "field.biologist@example.com",
            fullName: "Nikola Popovic",
            isVerified: true,
            settings: User.Settings(dataLicense: 1, imageLicense: 1, language: "en")
        )
    }

    func deleteCurrentUser(deleteObservations: Bool) async throws(SettingsDataFailure) {}
}

private final class PreviewLogoutUseCase: LogoutUseCase {
    func logout() async {}
}

private final class PreviewSettingsPreferencesRepository: SettingsPreferencesRepository {
    private var preferences = SettingsPreferences(
        alwaysUseEnglishNames: true,
        defaultsToAdult: false,
        projectName: "Biologer field research",
        automaticTaxonDownload: .onlyWiFi
    )

    func load() -> SettingsPreferences {
        preferences
    }

    func save(_ preferences: SettingsPreferences) {
        self.preferences = preferences
    }
}

private final class PreviewSettingsLicenseRepository: SettingsLicenseRepository {
    private let dataOptions = [
        SettingsLicenseOption(
            id: 1,
            title: "CC BY 4.0",
            details: "Others may share and adapt the data with attribution."
        ),
        SettingsLicenseOption(
            id: 2,
            title: "CC BY-SA 4.0",
            details: "Adaptations must be shared under the same license."
        )
    ]

    private let imageOptions = [
        SettingsLicenseOption(
            id: 3,
            title: "CC BY-NC 4.0",
            details: "Images may be reused for non-commercial purposes."
        ),
        SettingsLicenseOption(
            id: 4,
            title: "All rights reserved",
            details: "Permission is required before an image can be reused."
        )
    ]

    private var selectedOptionIDs: [SettingsLicenseKind: Int] = [
        .data: 1,
        .image: 3
    ]

    func options(for kind: SettingsLicenseKind) -> [SettingsLicenseOption] {
        switch kind {
        case .data:
            dataOptions
        case .image:
            imageOptions
        }
    }

    func selectedOption(for kind: SettingsLicenseKind) -> SettingsLicenseOption {
        let availableOptions = options(for: kind)
        let selectedID = selectedOptionIDs[kind]
        return availableOptions.first(where: { $0.id == selectedID }) ?? availableOptions[0]
    }

    func save(_ option: SettingsLicenseOption, for kind: SettingsLicenseKind) {
        guard options(for: kind).contains(where: { $0.id == option.id }) else {
            return
        }
        selectedOptionIDs[kind] = option.id
    }
}

private final class PreviewDownloadedTaxaRepository: DownloadedTaxaRepository {
    private var containsDownloadedTaxa = true

    func hasDownloadedTaxa() -> Bool {
        containsDownloadedTaxa
    }

    func resetDownloadedTaxa() {
        containsDownloadedTaxa = false
    }
}
