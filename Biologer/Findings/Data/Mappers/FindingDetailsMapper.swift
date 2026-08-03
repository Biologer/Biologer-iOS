import Foundation

enum FindingDetailsMapper {
    static func map(_ finding: DBFinding) -> FindingDetails {
        FindingDetails(
            id: finding.id,
            taxonName: finding.taxon?.name ?? "",
            photos: finding.images.compactMap(mapPhoto),
            developmentStageName: nonEmpty(finding.devStage?.name),
            atlasCodeName: nonEmpty(finding.atlasCode?.name),
            location: finding.location.map(mapLocation),
            individuals: mapIndividuals(finding.individuals),
            observations: finding.observations.compactMap(mapObservation),
            comment: nonEmpty(finding.comment),
            habitat: nonEmpty(finding.habitat),
            foundOn: nonEmpty(finding.foundOn),
            foundDead: nonEmpty(finding.foundDead),
            uploadStatus: finding.isUploaded ? .uploaded : .pending,
            createdAt: finding.dateOfCreation
        )
    }

    private static func mapPhoto(_ photo: DBFindingImage) -> FindingPhoto? {
        let imageData = photo.image.isEmpty ? nil : photo.image
        let remoteURL = nonEmpty(photo.url).flatMap(URL.init(string:))

        guard imageData != nil || remoteURL != nil else {
            return nil
        }

        return FindingPhoto(
            name: photo.name,
            imageData: imageData,
            remoteURL: remoteURL
        )
    }

    private static func mapLocation(_ location: DBFindingLocation) -> FindingDetailsLocation {
        FindingDetailsLocation(
            latitude: location.latitude,
            longitude: location.longitude,
            altitude: location.altitude,
            accuracy: location.accuracy
        )
    }

    private static func mapIndividuals(
        _ individuals: DBFindingIndividuals?
    ) -> FindingDetailsIndividuals {
        FindingDetailsIndividuals(
            total: individualValue(individuals?.all),
            male: individualValue(individuals?.male),
            female: individualValue(individuals?.female)
        )
    }

    private static func individualValue(_ individual: DBFindingIndividual?) -> Int? {
        guard let individual, individual.isSelected || individual.value > 0 else {
            return nil
        }
        return individual.value
    }

    private static func mapObservation(_ observation: DBFindingObservation) -> String? {
        guard observation.isSelected else { return nil }
        return nonEmpty(observation.title)
    }

    private static func nonEmpty(_ value: String?) -> String? {
        let value = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return value?.isEmpty == false ? value : nil
    }
}
