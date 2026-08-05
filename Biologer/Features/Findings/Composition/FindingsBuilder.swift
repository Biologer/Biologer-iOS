import RealmSwift
import SwiftUI
import UIKit

@MainActor
final class FindingsBuilder {
    private let realmConfiguration: Realm.Configuration
    private let remoteRepository: FindingRemoteUploadRepository
    private let dataLicenseStorage: LicenseStorage
    private let imageLicenseStorage: LicenseStorage
    private let settingsStorage: SettingsStorage
    private let userStorage: UserStorage

    init(
        realmConfiguration: Realm.Configuration = RealmManager.realmConfig(),
        remoteRepository: FindingRemoteUploadRepository,
        dataLicenseStorage: LicenseStorage,
        imageLicenseStorage: LicenseStorage,
        settingsStorage: SettingsStorage,
        userStorage: UserStorage
    ) {
        self.realmConfiguration = realmConfiguration
        self.remoteRepository = remoteRepository
        self.dataLicenseStorage = dataLicenseStorage
        self.imageLicenseStorage = imageLicenseStorage
        self.settingsStorage = settingsStorage
        self.userStorage = userStorage
    }

    func makeViewController(
        controller: FindingsFlowController,
        onAddFinding: @escaping Observer<Void>,
        onEditFinding: @escaping Observer<UUID>
    ) -> UIViewController {
        UIHostingController(
            rootView: makeFlow(
                controller: controller,
                onAddFinding: onAddFinding,
                onEditFinding: onEditFinding
            )
        )
    }

    func makeFlow(
        controller: FindingsFlowController,
        onAddFinding: @escaping Observer<Void>,
        onEditFinding: @escaping Observer<UUID>
    ) -> FindingsFlow {
        let repository = RealmFindingsRepository(
            configuration: realmConfiguration
        )
        let uploadRepository = RealmFindingUploadRepository(
            configuration: realmConfiguration,
            remoteRepository: remoteRepository,
            dataLicenseStorage: dataLicenseStorage,
            imageLicenseStorage: imageLicenseStorage,
            settingsStorage: settingsStorage
        )
        let submissionAccess = DefaultCheckFindingSubmissionAccessUseCase(
            repository: StoredFindingSubmissionAccessRepository(
                userStorage: userStorage
            )
        )
        return FindingsFlow(
            controller: controller,
            listUseCases: makeListUseCases(repository: repository),
            getFindingDetails: DefaultGetFindingDetailsUseCase(
                repository: repository
            ),
            uploadFindings: DefaultUploadFindingsUseCase(
                repository: uploadRepository
            ),
            checkSubmissionAccess: submissionAccess,
            onAddFinding: onAddFinding,
            onEditFinding: onEditFinding
        )
    }

    private func makeListUseCases(
        repository: RealmFindingsRepository
    ) -> FindingsUseCases {
        FindingsUseCases(
            getFindings: DefaultGetFindingsUseCase(repository: repository),
            deleteFinding: DefaultDeleteFindingUseCase(repository: repository),
            deleteFindings: DefaultDeleteFindingsUseCase(repository: repository),
            deleteAllFindings: DefaultDeleteAllFindingsUseCase(repository: repository)
        )
    }
}
