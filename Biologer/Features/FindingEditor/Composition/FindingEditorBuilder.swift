import RealmSwift
import SwiftUI
import UIKit

@MainActor
final class FindingEditorBuilder {
    private let realmConfiguration: Realm.Configuration
    private let altitudeRepository: FindingAltitudeRepository
    private let taxonSyncComposition: TaxonSyncComposition

    init(
        realmConfiguration: Realm.Configuration = RealmManager.realmConfig(),
        altitudeRepository: FindingAltitudeRepository,
        taxonSyncComposition: TaxonSyncComposition
    ) {
        self.realmConfiguration = realmConfiguration
        self.altitudeRepository = altitudeRepository
        self.taxonSyncComposition = taxonSyncComposition
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
            taxonSyncComposition: taxonSyncComposition,
            onSaved: onSaved,
            onUnsavedChangesChanged: onUnsavedChangesChanged
        )
    }
}
