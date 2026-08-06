import Foundation

struct FindingEditorDraft: Equatable {
    var id: UUID
    var location: FindingEditorLocation?
    var photos: [FindingEditorPhoto]
    var taxon: FindingEditorTaxon?
    var taxonName: String
    var atlasCode: FindingEditorOption?
    var developmentStage: FindingEditorOption?
    var individualEntryMode: FindingIndividualEntryMode
    var totalIndividuals: Int
    var maleIndividuals: Int
    var femaleIndividuals: Int
    var observations: [FindingEditorObservation]
    var comment: String
    var habitat: String
    var foundOn: String
    var isFoundDead: Bool
    var causeOfDeath: String
    var isUploaded: Bool
    var createdAt: Date

    static func empty(
        id: UUID = UUID(),
        location: FindingEditorLocation? = nil,
        observations: [FindingEditorObservation] = [],
        createdAt: Date = Date()
    ) -> FindingEditorDraft {
        FindingEditorDraft(
            id: id,
            location: location,
            photos: [],
            taxon: nil,
            taxonName: "",
            atlasCode: nil,
            developmentStage: nil,
            individualEntryMode: .total,
            totalIndividuals: 1,
            maleIndividuals: 0,
            femaleIndividuals: 0,
            observations: observations,
            comment: "",
            habitat: "",
            foundOn: "",
            isFoundDead: false,
            causeOfDeath: "",
            isUploaded: false,
            createdAt: createdAt
        )
    }
}

struct FindingEditorLocation: Equatable, Hashable {
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var accuracy: Double
}

struct FindingEditorPhoto: Identifiable, Equatable {
    let id: UUID
    var name: String
    var imageData: Data?
    var remoteURL: URL?

    init(
        id: UUID = UUID(),
        name: String,
        imageData: Data?,
        remoteURL: URL?
    ) {
        self.id = id
        self.name = name
        self.imageData = imageData
        self.remoteURL = remoteURL
    }
}

struct FindingEditorTaxon: Equatable {
    var apiID: Int?
    var name: String
    var usesAtlasCodes: Bool
    var developmentStages: [FindingEditorOption]
    var translations: [FindingEditorTaxonTranslation]
}

struct FindingEditorTaxonTranslation: Equatable {
    var id: Int
    var taxonID: Int
    var locale: String
    var nativeName: String
    var details: String
}

struct FindingEditorOption: Identifiable, Equatable, Hashable {
    var id: Int
    var name: String
}

struct FindingEditorObservation: Identifiable, Equatable {
    var id: Int
    var name: String
    var isSelected: Bool
}

enum FindingIndividualEntryMode: String, CaseIterable, Equatable {
    case total
    case gender
}
