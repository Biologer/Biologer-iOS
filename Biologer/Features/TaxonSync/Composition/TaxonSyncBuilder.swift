import Foundation
import RealmSwift

@MainActor
final class TaxonSyncBuilder {
    private let apiClient: APIClientProtocol
    private let environmentStorage: EnvironmentStorage
    private let realmConfiguration: Realm.Configuration
    private let bundle: Bundle
    private let pageSize: Int

    private lazy var controller: TaxonSyncController = {
        TaxonSyncController(
            catalogRepository: RealmTaxonCatalogRepository(
                configuration: realmConfiguration
            ),
            initialCatalogRepository: CSVInitialTaxonCatalogRepository(
                bundle: bundle
            ),
            updatesRepository: APITaxonUpdatesRepository(
                client: apiClient
            ),
            metadataRepository: UserDefaultsTaxonSyncMetadataRepository(),
            pageSize: pageSize
        )
    }()

    init(
        apiClient: APIClientProtocol,
        environmentStorage: EnvironmentStorage,
        realmConfiguration: Realm.Configuration = RealmManager.realmConfig(),
        bundle: Bundle = .main,
        pageSize: Int = APIConstants.taxonsPerPage
    ) {
        self.apiClient = apiClient
        self.environmentStorage = environmentStorage
        self.realmConfiguration = realmConfiguration
        self.bundle = bundle
        self.pageSize = pageSize
    }

    func makeComposition() -> TaxonSyncComposition {
        TaxonSyncComposition(
            useCases: TaxonSyncUseCases(
                getState: DefaultGetTaxonSyncStateUseCase(
                    controller: controller
                ),
                observeState: DefaultObserveTaxonSyncStateUseCase(
                    controller: controller
                ),
                checkForUpdates: DefaultCheckTaxonUpdatesUseCase(
                    controller: controller
                ),
                start: DefaultStartTaxonSyncUseCase(
                    controller: controller
                ),
                pause: DefaultPauseTaxonSyncUseCase(
                    controller: controller
                ),
                resume: DefaultResumeTaxonSyncUseCase(
                    controller: controller
                )
            ),
            scopeProvider: EnvironmentTaxonCatalogScopeProvider(
                environmentStorage: environmentStorage
            )
        )
    }
}
