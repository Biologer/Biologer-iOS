import SwiftUI
import UIKit

struct FindingsFlow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            makeFlow()
                .previewDisplayName("Findings flow V2")

            makeFlow()
                .preferredColorScheme(.dark)
                .previewDisplayName("Findings flow V2 - Dark")
        }
    }

    static func makeFlow(
        onAddFinding: @escaping Observer<Void> = { _ in },
        onEditFinding: @escaping Observer<UUID> = { _ in }
    ) -> FindingsFlow {
        let repository = PreviewFindingsFlowRepository(
            findings: previewFindings
        )
        let listUseCases = FindingsUseCases(
            getFindings: DefaultGetFindingsUseCase(repository: repository),
            deleteFinding: DefaultDeleteFindingUseCase(repository: repository),
            deleteFindings: DefaultDeleteFindingsUseCase(repository: repository),
            deleteAllFindings: DefaultDeleteAllFindingsUseCase(repository: repository)
        )
        let uploadFindings = PreviewUploadFindingsUseCase(
            onUpload: repository.markAsUploaded
        )

        return FindingsFlow(
            controller: FindingsFlowController(),
            listUseCases: listUseCases,
            getFindingDetails: DefaultGetFindingDetailsUseCase(
                repository: repository
            ),
            uploadFindings: uploadFindings,
            checkSubmissionAccess: PreviewFindingSubmissionAccessUseCase(),
            onAddFinding: onAddFinding,
            onEditFinding: onEditFinding
        )
    }

    private static let previewFindings = [
        FindingDetails(
            id: UUID(),
            taxonName: "Salamandra salamandra",
            photos: [
                photo(named: "intro2"),
                photo(named: "taxon_background")
            ],
            developmentStageName: "Adult",
            atlasCodeName: nil,
            location: FindingDetailsLocation(
                latitude: 44.78657,
                longitude: 20.44892,
                altitude: 284,
                accuracy: 5.4
            ),
            individuals: FindingDetailsIndividuals(
                total: 7,
                male: 3,
                female: 4
            ),
            observations: ["Calling"],
            comment: "Observed after light rain.",
            habitat: "Mixed deciduous forest",
            foundOn: "Wet leaf litter",
            foundDead: nil,
            uploadStatus: .pending,
            createdAt: Date(timeIntervalSince1970: 1_784_158_400)
        ),
        FindingDetails(
            id: UUID(),
            taxonName: "Zerynthia polyxena",
            photos: [photo(named: "intro1")],
            developmentStageName: "Larva",
            atlasCodeName: nil,
            location: FindingDetailsLocation(
                latitude: 45.26714,
                longitude: 19.83355,
                altitude: 78,
                accuracy: 3.2
            ),
            individuals: FindingDetailsIndividuals(
                total: 12,
                male: nil,
                female: nil
            ),
            observations: [],
            comment: nil,
            habitat: "Meadow edge",
            foundOn: "Aristolochia clematitis",
            foundDead: nil,
            uploadStatus: .uploaded,
            createdAt: Date(timeIntervalSince1970: 1_783_899_200)
        ),
        FindingDetails(
            id: UUID(),
            taxonName: "Alcedo atthis",
            photos: [],
            developmentStageName: "Adult",
            atlasCodeName: "Probable breeding",
            location: FindingDetailsLocation(
                latitude: 43.32090,
                longitude: 21.89576,
                altitude: 196,
                accuracy: 8
            ),
            individuals: FindingDetailsIndividuals(
                total: 2,
                male: nil,
                female: nil
            ),
            observations: ["Calling", "In flight"],
            comment: "Two individuals followed the river downstream.",
            habitat: "River bank",
            foundOn: nil,
            foundDead: nil,
            uploadStatus: .pending,
            createdAt: Date(timeIntervalSince1970: 1_783_468_800)
        ),
        FindingDetails(
            id: UUID(),
            taxonName: "Quercus robur",
            photos: [],
            developmentStageName: nil,
            atlasCodeName: nil,
            location: nil,
            individuals: FindingDetailsIndividuals(
                total: nil,
                male: nil,
                female: nil
            ),
            observations: [],
            comment: nil,
            habitat: nil,
            foundOn: nil,
            foundDead: nil,
            uploadStatus: .uploaded,
            createdAt: Date(timeIntervalSince1970: 1_782_950_400)
        )
    ]

    private static func photo(named imageName: String) -> FindingPhoto {
        FindingPhoto(
            name: "\(imageName).png",
            imageData: UIImage(named: imageName)?.pngData(),
            remoteURL: nil
        )
    }
}

private final class PreviewFindingsFlowRepository: FindingsRepository, FindingDetailsRepository {
    private var findings: [FindingDetails]

    init(findings: [FindingDetails]) {
        self.findings = findings
    }

    func getAll() throws -> [FindingSummary] {
        findings.map { finding in
            FindingSummary(
                id: finding.id,
                taxonName: finding.taxonName,
                thumbnailData: finding.photos.first?.imageData,
                developmentStageName: finding.developmentStageName ?? "",
                uploadStatus: finding.uploadStatus
            )
        }
    }

    func get(id: UUID) throws -> FindingDetails {
        guard let finding = findings.first(where: { $0.id == id }) else {
            throw FindingsRepositoryError.findingNotFound(id)
        }
        return finding
    }

    func delete(id: UUID) throws {
        guard findings.contains(where: { $0.id == id }) else {
            throw FindingsRepositoryError.findingNotFound(id)
        }
        findings.removeAll(where: { $0.id == id })
    }

    func delete(ids: [UUID]) throws {
        if let missingID = ids.first(where: { id in
            !findings.contains(where: { $0.id == id })
        }) {
            throw FindingsRepositoryError.findingNotFound(missingID)
        }
        let selectedIDs = Set(ids)
        findings.removeAll(where: { selectedIDs.contains($0.id) })
    }

    func deleteAll() throws {
        findings.removeAll()
    }

    func markAsUploaded(id: UUID) throws {
        guard let index = findings.firstIndex(where: { $0.id == id }) else {
            throw FindingsRepositoryError.findingNotFound(id)
        }
        findings[index] = findings[index].withUploadStatus(.uploaded)
    }
}

private extension FindingDetails {
    func withUploadStatus(_ uploadStatus: FindingUploadStatus) -> FindingDetails {
        FindingDetails(
            id: id,
            taxonName: taxonName,
            photos: photos,
            developmentStageName: developmentStageName,
            atlasCodeName: atlasCodeName,
            location: location,
            individuals: individuals,
            observations: observations,
            comment: comment,
            habitat: habitat,
            foundOn: foundOn,
            foundDead: foundDead,
            uploadStatus: uploadStatus,
            createdAt: createdAt
        )
    }
}
