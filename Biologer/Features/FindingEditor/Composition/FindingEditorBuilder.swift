import RealmSwift
import SwiftUI
import UIKit

@MainActor
final class FindingEditorBuilder {
    private let realmConfiguration: Realm.Configuration
    private let altitudeService: GetAltitudeService

    init(
        realmConfiguration: Realm.Configuration = RealmManager.realmConfig(),
        altitudeService: GetAltitudeService
    ) {
        self.realmConfiguration = realmConfiguration
        self.altitudeService = altitudeService
    }

    func makeViewController(
        mode: FindingEditorMode,
        onSaved: @escaping Observer<UUID>,
        onUnsavedChangesChanged: @escaping Observer<Bool>
    ) -> UIViewController {
        UIHostingController(
            rootView: makeFlow(
                mode: mode,
                onSaved: onSaved,
                onUnsavedChangesChanged: onUnsavedChangesChanged
            )
        )
    }

    func makeFlow(
        mode: FindingEditorMode,
        onSaved: @escaping Observer<UUID>,
        onUnsavedChangesChanged: @escaping Observer<Bool>
    ) -> FindingEditorFlow {
        let editorRepository = RealmFindingEditorRepository(
            configuration: realmConfiguration
        )
        let taxonRepository = RealmFindingTaxonSearchRepository(
            configuration: realmConfiguration
        )
        let locationRepository = CoreLocationFindingCurrentLocationRepository()
        let altitudeRepository = ServiceFindingAltitudeRepository(
            service: altitudeService
        )

        return FindingEditorFlow(
            mode: mode,
            loadFinding: DefaultLoadFindingEditorUseCase(
                repository: editorRepository
            ),
            saveFinding: DefaultSaveFindingEditorUseCase(
                repository: editorRepository
            ),
            searchTaxa: DefaultSearchFindingTaxaUseCase(
                repository: taxonRepository
            ),
            locationUseCases: FindingLocationUseCases(
                observeCurrentLocation: DefaultObserveCurrentFindingLocationUseCase(
                    repository: locationRepository
                ),
                resolveLocation: DefaultResolveFindingLocationUseCase(
                    altitudeRepository: altitudeRepository
                )
            ),
            onSaved: onSaved,
            onUnsavedChangesChanged: onUnsavedChangesChanged
        )
    }
}
