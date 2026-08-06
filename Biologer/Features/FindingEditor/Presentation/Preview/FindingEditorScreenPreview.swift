import SwiftUI
import UIKit

struct FindingEditorScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            makeFlow(mode: .create)
                .previewDisplayName("Create finding ")

            makeFlow(mode: .edit(editDraft.id))
                .previewDisplayName("Edit finding ")

            makeFlow(mode: .edit(editDraft.id))
                .preferredColorScheme(.dark)
                .previewDisplayName("Edit finding  - Dark")
        }
    }

    static func makeFlow(
        mode: FindingEditorMode,
        onSaved: @escaping Observer<UUID> = { _ in },
        onUnsavedChangesChanged: @escaping Observer<Bool> = { _ in }
    ) -> FindingEditorFlow {
        var draft = mode.findingID == nil ? createDraft : editDraft
        if let findingID = mode.findingID {
            draft.id = findingID
        }
        let repository = PreviewFindingEditorRepository(draft: draft)

        let useCases = FindingEditorUseCases(
            loadFinding: DefaultLoadFindingEditorUseCase(
                repository: repository
            ),
            saveFinding: DefaultSaveFindingEditorUseCase(
                repository: repository
            ),
            searchTaxa: DefaultSearchFindingTaxaUseCase(
                repository: PreviewFindingTaxonSearchRepository()
            ),
            location: FindingLocationUseCases(
                observeCurrentLocation: PreviewObserveCurrentFindingLocationUseCase(),
                resolveLocation: PreviewResolveFindingLocationUseCase()
            )
        )

        return FindingEditorBuilder(
            useCases: useCases,
            taxonSyncComposition: TaxonSyncPreviewFactory.makeComposition()
        ).makeFlow(
            mode: mode,
            onSaved: onSaved,
            onUnsavedChangesChanged: onUnsavedChangesChanged
        )
    }

    private static let createDraft = FindingEditorDraft(
        id: UUID(),
        location: FindingEditorLocation(
            latitude: 44.78657,
            longitude: 20.44892,
            altitude: 284,
            accuracy: 5.4
        ),
        photos: [],
        taxon: nil,
        taxonName: "",
        atlasCode: nil,
        developmentStage: nil,
        individualEntryMode: .total,
        totalIndividuals: 1,
        maleIndividuals: 0,
        femaleIndividuals: 0,
        observations: previewObservations,
        comment: "",
        habitat: "",
        foundOn: "",
        isFoundDead: false,
        causeOfDeath: "",
        isUploaded: false,
        createdAt: Date()
    )

    private static let editDraft = FindingEditorDraft(
        id: UUID(),
        location: FindingEditorLocation(
            latitude: 44.78657,
            longitude: 20.44892,
            altitude: 284,
            accuracy: 5.4
        ),
        photos: [
            FindingEditorPhoto(
                name: "salamander-1.jpg",
                imageData: imageData(named: "intro2"),
                remoteURL: nil
            ),
            FindingEditorPhoto(
                name: "salamander-2.jpg",
                imageData: imageData(named: "taxon_background"),
                remoteURL: nil
            )
        ],
        taxon: FindingEditorTaxon(
            apiID: 1042,
            name: "Salamandra salamandra",
            usesAtlasCodes: true,
            developmentStages: [
                FindingEditorOption(id: 1, name: "Larva"),
                FindingEditorOption(id: 2, name: "Juvenile"),
                FindingEditorOption(id: 3, name: "Adult")
            ],
            translations: []
        ),
        taxonName: "Salamandra salamandra",
        atlasCode: FindingEditorOption(id: 3, name: "Possible breeding"),
        developmentStage: FindingEditorOption(id: 3, name: "Adult"),
        individualEntryMode: .gender,
        totalIndividuals: 0,
        maleIndividuals: 3,
        femaleIndividuals: 4,
        observations: [
            FindingEditorObservation(id: 1, name: "Calling", isSelected: true),
            FindingEditorObservation(id: 2, name: "Exuviae", isSelected: false),
            FindingEditorObservation(id: 3, name: "Roadkill", isSelected: false)
        ],
        comment: "Observed after light rain during an evening field survey.",
        habitat: "Mixed deciduous forest near a small stream",
        foundOn: "Wet leaf litter",
        isFoundDead: false,
        causeOfDeath: "",
        isUploaded: false,
        createdAt: Date(timeIntervalSince1970: 1_784_158_400)
    )

    private static let previewObservations = [
        FindingEditorObservation(id: 1, name: "Calling", isSelected: false),
        FindingEditorObservation(id: 2, name: "Exuviae", isSelected: false),
        FindingEditorObservation(id: 3, name: "Roadkill", isSelected: false)
    ]

    private static func imageData(named imageName: String) -> Data? {
        UIImage(named: imageName)?.jpegData(compressionQuality: 0.9)
    }
}

private final class PreviewObserveCurrentFindingLocationUseCase:
    ObserveCurrentFindingLocationUseCase {
    func start(
        onLocation: @escaping (FindingEditorLocation) -> Void,
        onError: @escaping (FindingLocationRepositoryError) -> Void
    ) {}

    func stop() {}
}

private final class PreviewResolveFindingLocationUseCase: ResolveFindingLocationUseCase {
    func execute(_ location: FindingEditorLocation) async -> FindingEditorLocation {
        location
    }
}

private final class PreviewFindingEditorRepository: FindingEditorRepository {
    private var draft: FindingEditorDraft

    init(draft: FindingEditorDraft) {
        self.draft = draft
    }

    func makeNewDraft() throws -> FindingEditorDraft {
        draft
    }

    func getDraft(id: UUID) throws -> FindingEditorDraft {
        guard id == draft.id else {
            throw FindingEditorRepositoryError.findingNotFound(id)
        }
        return draft
    }

    func create(_ draft: FindingEditorDraft) throws {
        self.draft = draft
    }

    func update(_ draft: FindingEditorDraft) throws {
        guard draft.id == self.draft.id else {
            throw FindingEditorRepositoryError.findingNotFound(draft.id)
        }
        self.draft = draft
    }
}

private final class PreviewFindingTaxonSearchRepository: FindingTaxonSearchRepository {
    private let taxa = [
        FindingEditorTaxon(
            apiID: 1042,
            name: "Salamandra salamandra (Fire salamander)",
            usesAtlasCodes: false,
            developmentStages: [
                FindingEditorOption(id: 1, name: "Larva"),
                FindingEditorOption(id: 2, name: "Adult")
            ],
            translations: []
        ),
        FindingEditorTaxon(
            apiID: 1043,
            name: "Salamandra atra (Alpine salamander)",
            usesAtlasCodes: false,
            developmentStages: [],
            translations: []
        ),
        FindingEditorTaxon(
            apiID: 2021,
            name: "Salix alba (White willow)",
            usesAtlasCodes: false,
            developmentStages: [],
            translations: []
        )
    ]

    func search(query: String, limit: Int) throws -> [FindingEditorTaxon] {
        Array(
            taxa.filter {
                $0.name.localizedCaseInsensitiveContains(query)
            }
            .prefix(limit)
        )
    }
}
