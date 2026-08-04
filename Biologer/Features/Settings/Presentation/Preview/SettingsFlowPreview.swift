import SwiftUI

struct SettingsFlow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            makeSettingsFlow()
                .previewDisplayName("Settings V2")

            makeSettingsFlow()
                .preferredColorScheme(.dark)
                .previewDisplayName("Settings V2 - Dark")
        }
    }

    static func makeSettingsFlow(
        onDownloadTaxa: @escaping Observer<Void> = { _ in },
        onLogout: @escaping Observer<Void> = { _ in },
        onDeleteAccount: @escaping Observer<Bool> = { _ in }
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

        return SettingsFlow(
            useCases: useCases,
            accountContextProvider: {
                SettingsAccountContext(
                    email: "field.biologist@example.com",
                    username: "Nikola Popovic",
                    environment: "https://dev.biologer.org"
                )
            },
            appVersion: "Version: 3.0.4 (Preview)",
            onOpenURL: { _ in },
            onDownloadTaxa: onDownloadTaxa,
            onLogout: onLogout,
            onDeleteAccount: onDeleteAccount,
            taxonSyncComposition: PreviewTaxonSyncComposition.make()
        )
    }
}

private enum PreviewTaxonSyncComposition {
    static func make() -> TaxonSyncComposition {
        let scope = TaxonCatalogScope(environmentHost: "dev.biologer.org")
        let status = TaxonCatalogStatus(
            scope: scope,
            availability: .ready,
            localTaxaCount: 1240,
            lastSuccessfulSyncTimestamp: nil
        )
        let state = PreviewStateUseCase(state: .idle(status))
        let actions = PreviewActionUseCase()
        return TaxonSyncComposition(
            useCases: TaxonSyncUseCases(
                getState: state,
                observeState: state,
                checkForUpdates: actions,
                start: actions,
                pause: actions,
                resume: actions
            ),
            scopeProvider: PreviewScopeProvider(scope: scope)
        )
    }
}

private struct PreviewStateUseCase: GetTaxonSyncStateUseCase, ObserveTaxonSyncStateUseCase {
    let state: TaxonSyncState

    func execute(scope: TaxonCatalogScope) async -> TaxonSyncState { state }

    func execute(scope: TaxonCatalogScope) async -> AsyncStream<TaxonSyncState> {
        AsyncStream { continuation in
            continuation.yield(state)
            continuation.finish()
        }
    }
}

private struct PreviewActionUseCase: CheckTaxonUpdatesUseCase, StartTaxonSyncUseCase, PauseTaxonSyncUseCase, ResumeTaxonSyncUseCase {
    func execute(scope: TaxonCatalogScope) async throws(TaxonSyncFailure) -> TaxonSyncCheckResult {
        .upToDate(.init(scope: scope, availability: .ready, localTaxaCount: 1240, lastSuccessfulSyncTimestamp: nil))
    }

    func execute(scope: TaxonCatalogScope) async {}
}

private struct PreviewScopeProvider: TaxonCatalogScopeProviding {
    let scope: TaxonCatalogScope
    func currentScope() -> TaxonCatalogScope? { scope }
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
