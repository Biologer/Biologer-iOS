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
        onFindingSelected: @escaping Observer<UUID>,
        onUploadFindings: @escaping Observer<Void>
    ) -> UIViewController {
        let viewModel = makeViewModel(
            onAddFinding: onAddFinding,
            onFindingSelected: onFindingSelected
        )
        let screen = NavigationStack {
            ListOfFindingsScreenV2(
                viewModel: viewModel,
                onUploadFindings: onUploadFindings
            )
        }
        return UIHostingController(rootView: screen)
    }

    private func makeViewModel(
        onAddFinding: @escaping Observer<Void>,
        onFindingSelected: @escaping Observer<UUID>
    ) -> ListOfFindingsV2ViewModel {
        ListOfFindingsV2ViewModel(
            useCases: makeUseCases(),
            onAddFinding: { onAddFinding(()) },
            onFindingSelected: onFindingSelected
        )
    }

    private func makeUseCases() -> FindingsUseCases {
        let repository = RealmFindingsRepository(
            configuration: realmConfiguration
        )
        return FindingsUseCases(
            getFindings: DefaultGetFindingsUseCase(repository: repository),
            deleteFinding: DefaultDeleteFindingUseCase(repository: repository),
            deleteAllFindings: DefaultDeleteAllFindingsUseCase(repository: repository)
        )
    }
}
