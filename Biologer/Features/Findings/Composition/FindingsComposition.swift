/// Builds the Findings feature and keeps its data implementations private.
final class FindingsComposition {
    struct Dependencies {
        let authenticatedAPIClient: APIClientProtocol
        let environmentProvider: CurrentEnvironmentProviding
        let licenseStorage: LicensePreferenceStorage
        let licenseOptionsProvider: LicenseOptionsProviding
        let settingsStorage: SettingsStorage
        let userStorage: UserStorage
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    private lazy var findingsRepository:
        FindingsRepository & FindingDetailsRepository = {
        RealmFindingsRepository(configuration: RealmManager.realmConfig())
    }()

    private lazy var remoteUploadRepository: FindingRemoteUploadRepository = {
        RemoteFindingUploadRepository(
            client: dependencies.authenticatedAPIClient,
            environmentProvider: dependencies.environmentProvider
        )
    }()

    private lazy var uploadRepository: FindingUploadRepository = {
        RealmFindingUploadRepository(
            configuration: RealmManager.realmConfig(),
            remoteRepository: remoteUploadRepository,
            licenseStorage: dependencies.licenseStorage,
            licenseOptionsProvider: dependencies.licenseOptionsProvider,
            settingsStorage: dependencies.settingsStorage
        )
    }()

    private lazy var submissionAccessRepository:
        FindingSubmissionAccessRepository = {
        StoredFindingSubmissionAccessRepository(
            userStorage: dependencies.userStorage
        )
    }()

    private lazy var useCases: FindingsUseCases = {
        let uploadFindings = DefaultUploadFindingsUseCase(
            repository: uploadRepository
        )
        let checkSubmissionAccess = DefaultCheckFindingSubmissionAccessUseCase(
            repository: submissionAccessRepository
        )

        return FindingsUseCases(
            list: ListOfFindingsUseCases(
                getFindings: DefaultGetFindingsUseCase(repository: findingsRepository),
                deleteFinding: DefaultDeleteFindingUseCase(repository: findingsRepository),
                deleteFindings: DefaultDeleteFindingsUseCase(repository: findingsRepository),
                deleteAllFindings: DefaultDeleteAllFindingsUseCase(
                    repository: findingsRepository
                ),
                uploadFindings: uploadFindings,
                checkSubmissionAccess: checkSubmissionAccess
            ),
            details: FindingDetailsUseCases(
                getFindingDetails: DefaultGetFindingDetailsUseCase(
                    repository: findingsRepository
                ),
                uploadFindings: uploadFindings,
                checkSubmissionAccess: checkSubmissionAccess
            )
        )
    }()

    lazy var flowBuilder = FindingsFlowBuilder(useCases: useCases)

    @MainActor
    lazy var flowController = FindingsFlowController()
}
