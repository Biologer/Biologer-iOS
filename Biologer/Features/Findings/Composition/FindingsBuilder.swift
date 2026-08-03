import RealmSwift
import SwiftUI
import UIKit

@MainActor
final class FindingsBuilder {
    private let realmConfiguration: Realm.Configuration
    private let remotePostService: PostFindingService
    private let uploadImageService: PostFindingImageService
    private let dataLicenseStorage: LicenseStorage
    private let imageLicenseStorage: LicenseStorage
    private let settingsStorage: SettingsStorage

    init(
        realmConfiguration: Realm.Configuration = RealmManager.realmConfig(),
        remotePostService: PostFindingService,
        uploadImageService: PostFindingImageService,
        dataLicenseStorage: LicenseStorage,
        imageLicenseStorage: LicenseStorage,
        settingsStorage: SettingsStorage
    ) {
        self.realmConfiguration = realmConfiguration
        self.remotePostService = remotePostService
        self.uploadImageService = uploadImageService
        self.dataLicenseStorage = dataLicenseStorage
        self.imageLicenseStorage = imageLicenseStorage
        self.settingsStorage = settingsStorage
    }

    func makeViewController(
        controller: FindingsFlowController,
        onAddFinding: @escaping Observer<Void>,
        onEditFinding: @escaping Observer<UUID>,
        onShowLocation: @escaping Observer<FindingDetailsLocation>
    ) -> UIViewController {
        UIHostingController(
            rootView: makeFlow(
                controller: controller,
                onAddFinding: onAddFinding,
                onEditFinding: onEditFinding,
                onShowLocation: onShowLocation
            )
        )
    }

    func makeFlow(
        controller: FindingsFlowController,
        onAddFinding: @escaping Observer<Void>,
        onEditFinding: @escaping Observer<UUID>,
        onShowLocation: @escaping Observer<FindingDetailsLocation>
    ) -> FindingsFlow {
        let repository = RealmFindingsRepository(
            configuration: realmConfiguration
        )
        let uploadRepository = RealmFindingUploadRepository(
            configuration: realmConfiguration,
            remotePostService: remotePostService,
            uploadImageService: uploadImageService,
            dataLicenseStorage: dataLicenseStorage,
            imageLicenseStorage: imageLicenseStorage,
            settingsStorage: settingsStorage
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
            onAddFinding: onAddFinding,
            onEditFinding: onEditFinding,
            onShowLocation: onShowLocation
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
