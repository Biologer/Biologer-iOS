import Foundation

/// Shared dependencies and ViewModel construction for every TaxonSync entry point.
struct TaxonSyncComposition {
    let service: TaxonSyncService
    let scopeProvider: TaxonCatalogScopeProviding

    init(
        authenticatedAPIClient: APIClientProtocol,
        environmentProvider: CurrentEnvironmentProviding,
        pageSize: Int
    ) {
        service = TaxonSyncController(
            catalogRepository: RealmTaxonCatalogRepository(
                configuration: RealmManager.realmConfig()
            ),
            initialCatalogRepository: CSVInitialTaxonCatalogRepository(
                bundle: .main
            ),
            updatesRepository: APITaxonUpdatesRepository(
                client: authenticatedAPIClient
            ),
            metadataRepository: UserDefaultsTaxonSyncMetadataRepository(),
            pageSize: pageSize
        )
        scopeProvider = EnvironmentTaxonCatalogScopeProvider(
            environmentProvider: environmentProvider
        )
    }

    init(
        service: TaxonSyncService,
        scopeProvider: TaxonCatalogScopeProviding
    ) {
        self.service = service
        self.scopeProvider = scopeProvider
    }

    @MainActor
    func makeViewModel() -> TaxonSyncViewModel {
        TaxonSyncViewModel(
            service: service,
            scopeProvider: scopeProvider
        )
    }
}
