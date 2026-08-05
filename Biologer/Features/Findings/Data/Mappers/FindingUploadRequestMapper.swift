import Foundation

enum FindingUploadComponent: Equatable {
    case male
    case female
    case total
    case fallback
}

struct FindingUploadSnapshot {
    let id: UUID
    let component: FindingUploadComponent
    let imageData: [Data]
    let atlasCode: Int
    let accuracy: Int
    let day: String
    let elevation: Int
    let foundDead: Int
    let foundDeadNote: String
    let foundOn: String
    let habitat: String
    let latitude: Double
    let longitude: Double
    let month: String
    let note: String
    let number: Int
    let observationTypeIDs: [Int]
    let sex: String
    let developmentStageID: Int?
    let taxonID: Int?
    let taxonSuggestion: String
    let time: String
    let year: String
}

enum FindingUploadRequestMapper {
    static func makeSnapshots(
        from finding: DBFinding,
        availableObservationTypeIDs: [Int]
    ) -> [FindingUploadSnapshot] {
        pendingIndividuals(from: finding.individuals).map { individual in
            FindingUploadSnapshot(
                id: finding.id,
                component: individual.component,
                imageData: finding.images.map(\.image),
                atlasCode: finding.atlasCode?.id ?? 0,
                accuracy: Int(finding.location?.accuracy ?? 0),
                day: String(finding.dateOfCreation.component(.day)),
                elevation: Int(finding.location?.altitude ?? 0),
                foundDead: finding.foundDead.isEmpty ? 0 : 1,
                foundDeadNote: finding.foundDead,
                foundOn: finding.foundOn,
                habitat: finding.habitat,
                latitude: finding.location?.latitude ?? 0,
                longitude: finding.location?.longitude ?? 0,
                month: String(finding.dateOfCreation.component(.month)),
                note: finding.comment,
                number: individual.number,
                observationTypeIDs: selectedObservationTypeIDs(
                    from: finding,
                    availableIDs: availableObservationTypeIDs
                ),
                sex: individual.sex,
                developmentStageID: finding.devStage?.id,
                taxonID: finding.taxon?.apiId,
                taxonSuggestion: finding.taxon?.name ?? "",
                time: finding.dateOfCreation.formattedHoursAndMinutes(),
                year: String(finding.dateOfCreation.component(.year))
            )
        }
    }

    static func makeRequest(
        from snapshot: FindingUploadSnapshot,
        photos: [FindingPhotoRequestBody],
        dataLicenseID: Int,
        projectName: String
    ) -> FindingRequestBody {
        FindingRequestBody(
            atlasCode: snapshot.atlasCode,
            accuracy: snapshot.accuracy,
            data_license: String(dataLicenseID),
            day: snapshot.day,
            elevation: snapshot.elevation,
            found_dead: snapshot.foundDead,
            found_dead_note: snapshot.foundDeadNote,
            found_on: snapshot.foundOn,
            habitat: snapshot.habitat,
            latitude: snapshot.latitude,
            longitude: snapshot.longitude,
            location: "",
            month: snapshot.month,
            note: snapshot.note,
            number: snapshot.number,
            observation_types_ids: snapshot.observationTypeIDs,
            photos: photos,
            project: projectName,
            sex: snapshot.sex,
            stage_id: snapshot.developmentStageID,
            taxon_id: snapshot.taxonID,
            taxon_suggestion: snapshot.taxonSuggestion,
            time: snapshot.time,
            year: snapshot.year
        )
    }

    private static func pendingIndividuals(
        from individuals: DBFindingIndividuals?
    ) -> [(component: FindingUploadComponent, sex: String, number: Int)] {
        var genderIndividuals: [(
            component: FindingUploadComponent,
            sex: String,
            number: Int
        )] = []

        if let male = individuals?.male,
           male.isSelected,
           male.value > 0,
           !male.isUploaded {
            genderIndividuals.append((.male, "male", male.value))
        }

        if let female = individuals?.female,
           female.isSelected,
           female.value > 0,
           !female.isUploaded {
            genderIndividuals.append((.female, "female", female.value))
        }

        if !genderIndividuals.isEmpty {
            return genderIndividuals
        }

        let hasGenderIndividuals = isActive(individuals?.male)
            || isActive(individuals?.female)
        if hasGenderIndividuals {
            return []
        }

        if let total = individuals?.all,
           total.isSelected,
           total.value > 0,
           !total.isUploaded {
            return [(.total, "", total.value)]
        }

        if isActive(individuals?.all) {
            return []
        }

        return [(.fallback, "", 1)]
    }

    private static func isActive(_ individual: DBFindingIndividual?) -> Bool {
        guard let individual else { return false }
        return individual.isSelected && individual.value > 0
    }

    private static func selectedObservationTypeIDs(
        from finding: DBFinding,
        availableIDs: [Int]
    ) -> [Int] {
        var selectedIDs: [Int] = []

        if let fieldObservationID = availableIDs.first {
            selectedIDs.append(fieldObservationID)
        }

        if !finding.images.isEmpty, availableIDs.indices.contains(1) {
            selectedIDs.append(availableIDs[1])
        }

        for (index, observation) in finding.observations.enumerated()
        where observation.isSelected && availableIDs.indices.contains(index) {
            selectedIDs.append(availableIDs[index])
        }

        return selectedIDs
    }
}
