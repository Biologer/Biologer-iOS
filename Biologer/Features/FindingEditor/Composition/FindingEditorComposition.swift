/// Builds the Finding Editor feature from shared app services.
final class FindingEditorComposition {
    struct Dependencies {
        let authenticatedAPIClient: APIClientProtocol
        let environmentProvider: CurrentEnvironmentProviding
        let taxonSyncComposition: TaxonSyncComposition
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    private lazy var editorRepository: FindingEditorRepository = {
        RealmFindingEditorRepository(configuration: RealmManager.realmConfig())
    }()

    private lazy var taxonSearchRepository: FindingTaxonSearchRepository = {
        RealmFindingTaxonSearchRepository(
            configuration: RealmManager.realmConfig()
        )
    }()

    private lazy var altitudeRepository: FindingAltitudeRepository = {
        RemoteFindingAltitudeRepository(
            client: dependencies.authenticatedAPIClient,
            environmentProvider: dependencies.environmentProvider
        )
    }()

    @MainActor
    lazy var flowBuilder: FindingEditorFlowBuilder = {
        let useCases = FindingEditorUseCases(
            loadFinding: DefaultLoadFindingEditorUseCase(
                repository: editorRepository
            ),
            saveFinding: DefaultSaveFindingEditorUseCase(
                repository: editorRepository
            ),
            searchTaxa: DefaultSearchFindingTaxaUseCase(
                repository: taxonSearchRepository
            ),
            location: FindingLocationUseCases(
                observeCurrentLocation: DefaultObserveCurrentFindingLocationUseCase(
                    repository: CoreLocationFindingCurrentLocationRepository()
                ),
                resolveLocation: DefaultResolveFindingLocationUseCase(
                    altitudeRepository: altitudeRepository
                )
            )
        )

        return FindingEditorFlowBuilder(
            useCases: useCases,
            taxonSyncComposition: dependencies.taxonSyncComposition
        )
    }()
}
