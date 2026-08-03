import Foundation
import RealmSwift

enum FindingEditorMapper {
    static func map(_ finding: DBFinding) -> FindingEditorDraft {
        let individuals = finding.individuals
        let hasSexSpecificCount = isActive(individuals?.male) || isActive(individuals?.female)

        return FindingEditorDraft(
            id: finding.id,
            location: finding.location.map(mapLocation),
            photos: finding.images.map(mapPhoto),
            taxon: finding.taxon.map(mapTaxon),
            taxonName: finding.taxon?.name ?? "",
            atlasCode: finding.atlasCode.map {
                FindingEditorOption(id: $0.id, name: $0.name)
            },
            developmentStage: finding.devStage.map {
                FindingEditorOption(id: $0.id, name: $0.name)
            },
            individualEntryMode: hasSexSpecificCount ? .gender : .total,
            totalIndividuals: activeValue(individuals?.all),
            maleIndividuals: activeValue(individuals?.male),
            femaleIndividuals: activeValue(individuals?.female),
            observations: finding.observations.map(mapObservation),
            comment: finding.comment,
            habitat: finding.habitat,
            foundOn: finding.foundOn,
            isFoundDead: !finding.foundDead.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            causeOfDeath: finding.foundDead,
            isUploaded: finding.isUploaded,
            createdAt: finding.dateOfCreation
        )
    }

    static func makeDatabaseFinding(from draft: FindingEditorDraft) -> DBFinding {
        let finding = DBFinding()
        finding.id = draft.id
        apply(draft, to: finding)
        return finding
    }

    static func apply(_ draft: FindingEditorDraft, to finding: DBFinding) {
        finding.location = draft.location.map(makeLocation)
        finding.images = makePhotos(draft.photos)
        finding.taxon = makeTaxon(from: draft)
        finding.atlasCode = draft.atlasCode.map {
            DBAtlasCode(id: $0.id, name: $0.name)
        }
        finding.devStage = draft.developmentStage.map {
            DBTaxonDevStage(id: $0.id, name: $0.name, taxonId: draft.taxon?.apiID ?? 0)
        }
        finding.individuals = makeIndividuals(from: draft)
        finding.observations = makeObservations(draft.observations)
        finding.comment = draft.comment
        finding.habitat = draft.habitat
        finding.foundOn = draft.foundOn
        finding.foundDead = draft.isFoundDead ? draft.causeOfDeath : ""
        finding.isUploaded = false
        finding.dateOfCreation = draft.createdAt
    }

    private static func mapLocation(_ location: DBFindingLocation) -> FindingEditorLocation {
        FindingEditorLocation(
            latitude: location.latitude,
            longitude: location.longitude,
            altitude: location.altitude,
            accuracy: location.accuracy
        )
    }

    private static func mapPhoto(_ photo: DBFindingImage) -> FindingEditorPhoto {
        FindingEditorPhoto(
            name: photo.name,
            imageData: photo.image.isEmpty ? nil : photo.image,
            remoteURL: photo.url.flatMap(URL.init(string:))
        )
    }

    private static func mapTaxon(_ taxon: DBFindingTaxon) -> FindingEditorTaxon {
        FindingEditorTaxon(
            apiID: taxon.apiId,
            name: taxon.name,
            usesAtlasCodes: taxon.isAtlasCode,
            developmentStages: taxon.devStage.map {
                FindingEditorOption(id: $0.id, name: $0.name)
            },
            translations: taxon.translation.map {
                FindingEditorTaxonTranslation(
                    id: $0.id,
                    taxonID: $0.taxonId,
                    locale: $0.locale,
                    nativeName: $0.nativeName,
                    details: $0.descriptionName
                )
            }
        )
    }

    private static func mapObservation(
        _ observation: DBFindingObservation
    ) -> FindingEditorObservation {
        FindingEditorObservation(
            id: observation.id,
            name: observation.title,
            isSelected: observation.isSelected
        )
    }

    private static func isActive(_ individual: DBFindingIndividual?) -> Bool {
        guard let individual else { return false }
        return individual.isSelected || individual.value > 0
    }

    private static func activeValue(_ individual: DBFindingIndividual?) -> Int {
        isActive(individual) ? max(individual?.value ?? 0, 0) : 0
    }

    private static func makeLocation(_ location: FindingEditorLocation) -> DBFindingLocation {
        DBFindingLocation(
            latitude: location.latitude,
            longitude: location.longitude,
            altitude: location.altitude,
            accuracy: location.accuracy
        )
    }

    private static func makePhotos(_ photos: [FindingEditorPhoto]) -> List<DBFindingImage> {
        let result = List<DBFindingImage>()
        photos.forEach { photo in
            result.append(
                DBFindingImage(
                    name: photo.name,
                    image: photo.imageData ?? Data(),
                    url: photo.remoteURL?.absoluteString
                )
            )
        }
        return result
    }

    private static func makeTaxon(from draft: FindingEditorDraft) -> DBFindingTaxon {
        let translations = List<DBTaxonTranslations>()
        let developmentStages = List<DBTaxonDevStage>()

        draft.taxon?.translations.forEach { translation in
            translations.append(
                DBTaxonTranslations(
                    id: translation.id,
                    taxonId: translation.taxonID,
                    locale: translation.locale,
                    nativeName: translation.nativeName,
                    descriptionName: translation.details
                )
            )
        }
        draft.taxon?.developmentStages.forEach { stage in
            developmentStages.append(
                DBTaxonDevStage(
                    id: stage.id,
                    name: stage.name,
                    taxonId: draft.taxon?.apiID ?? 0
                )
            )
        }

        return DBFindingTaxon(
            apiId: draft.taxon?.apiID,
            name: draft.taxonName.trimmingCharacters(in: .whitespacesAndNewlines),
            isAtlasCode: draft.taxon?.usesAtlasCodes ?? false,
            translation: translations,
            devStage: developmentStages
        )
    }

    private static func makeIndividuals(
        from draft: FindingEditorDraft
    ) -> DBFindingIndividuals {
        switch draft.individualEntryMode {
        case .total:
            return DBFindingIndividuals(
                male: nil,
                female: nil,
                all: DBFindingIndividual(
                    value: draft.totalIndividuals,
                    isSelected: true
                )
            )
        case .gender:
            return DBFindingIndividuals(
                male: draft.maleIndividuals > 0
                    ? DBFindingIndividual(value: draft.maleIndividuals, isSelected: true)
                    : nil,
                female: draft.femaleIndividuals > 0
                    ? DBFindingIndividual(value: draft.femaleIndividuals, isSelected: true)
                    : nil,
                all: nil
            )
        }
    }

    private static func makeObservations(
        _ observations: [FindingEditorObservation]
    ) -> List<DBFindingObservation> {
        let result = List<DBFindingObservation>()
        observations.forEach { observation in
            result.append(
                DBFindingObservation(
                    id: observation.id,
                    title: observation.name,
                    isSelected: observation.isSelected
                )
            )
        }
        return result
    }
}
