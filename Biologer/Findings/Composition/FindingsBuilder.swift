import RealmSwift
import SwiftUI
import UIKit

@MainActor
final class FindingsBuilder {
    private let realmConfiguration: Realm.Configuration

    init(
        realmConfiguration: Realm.Configuration = RealmManager.realmConfig()
    ) {
        self.realmConfiguration = realmConfiguration
    }

    func makeViewController(
        onAddFinding: @escaping Observer<Void>,
        onEditFinding: @escaping Observer<UUID>,
        onShowLocation: @escaping Observer<FindingDetailsLocation>,
        onUploadFindings: @escaping Observer<Void>
    ) -> UIViewController {
        let repository = RealmFindingsRepository(
            configuration: realmConfiguration
        )
        let screen = FindingsFlow(
            listUseCases: makeListUseCases(repository: repository),
            getFindingDetails: DefaultGetFindingDetailsUseCase(
                repository: repository
            ),
            onAddFinding: onAddFinding,
            onEditFinding: onEditFinding,
            onShowLocation: onShowLocation,
            onUploadFindings: onUploadFindings
        )
        return UIHostingController(rootView: screen)
    }

    private func makeListUseCases(
        repository: RealmFindingsRepository
    ) -> FindingsUseCases {
        FindingsUseCases(
            getFindings: DefaultGetFindingsUseCase(repository: repository),
            deleteFinding: DefaultDeleteFindingUseCase(repository: repository),
            deleteAllFindings: DefaultDeleteAllFindingsUseCase(repository: repository)
        )
    }
}
