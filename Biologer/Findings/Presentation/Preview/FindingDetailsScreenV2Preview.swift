import SwiftUI
import UIKit

struct FindingDetailsScreenV2_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            makeScreen(details: detailedFinding)
                .previewDisplayName("Finding details V2")

            makeScreen(details: detailedFinding)
                .preferredColorScheme(.dark)
                .previewDisplayName("Finding details V2 - Dark")

            makeScreen(details: minimalFinding)
                .previewDisplayName("Finding details V2 - Minimal")
        }
    }

    private static func makeScreen(details: FindingDetails) -> some View {
        let repository = PreviewFindingDetailsRepository(details: details)
        let uploadFindings = PreviewUploadFindingsUseCase(
            onUpload: repository.markAsUploaded
        )

        return NavigationStack {
            FindingDetailsScreenV2(
                viewModel: FindingDetailsV2ViewModel(
                    findingID: details.id,
                    getFindingDetails: DefaultGetFindingDetailsUseCase(
                        repository: repository
                    ),
                    uploadFindings: uploadFindings,
                    onEditFinding: { _ in },
                    onShowLocation: { _ in }
                )
            )
        }
    }

    private static let detailedFinding = FindingDetails(
        id: UUID(),
        taxonName: "Salamandra salamandra",
        photos: [
            FindingPhoto(
                name: "salamander-1.jpg",
                imageData: imageData(named: "intro2"),
                remoteURL: nil
            ),
            FindingPhoto(
                name: "salamander-2.jpg",
                imageData: imageData(named: "taxon_background"),
                remoteURL: nil
            ),
            FindingPhoto(
                name: "salamander-3.jpg",
                imageData: imageData(named: "intro3"),
                remoteURL: nil
            )
        ],
        developmentStageName: "Adult",
        atlasCodeName: "Possible breeding",
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
        observations: ["Calling", "Found under a fallen tree"],
        comment: "Observed after light rain during an evening field survey.",
        habitat: "Mixed deciduous forest near a small stream",
        foundOn: "Wet leaf litter",
        foundDead: nil,
        uploadStatus: .pending,
        createdAt: Date(timeIntervalSince1970: 1_784_158_400)
    )

    private static let minimalFinding = FindingDetails(
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
        createdAt: Date(timeIntervalSince1970: 1_784_158_400)
    )

    private static func imageData(named imageName: String) -> Data? {
        UIImage(named: imageName)?.pngData()
    }
}

private final class PreviewFindingDetailsRepository: FindingDetailsRepository {
    private var details: FindingDetails

    init(details: FindingDetails) {
        self.details = details
    }

    func get(id: UUID) throws -> FindingDetails {
        guard details.id == id else {
            throw FindingsRepositoryError.findingNotFound(id)
        }
        return details
    }

    func markAsUploaded(id: UUID) throws {
        guard details.id == id else {
            throw FindingsRepositoryError.findingNotFound(id)
        }
        details = FindingDetails(
            id: details.id,
            taxonName: details.taxonName,
            photos: details.photos,
            developmentStageName: details.developmentStageName,
            atlasCodeName: details.atlasCodeName,
            location: details.location,
            individuals: details.individuals,
            observations: details.observations,
            comment: details.comment,
            habitat: details.habitat,
            foundOn: details.foundOn,
            foundDead: details.foundDead,
            uploadStatus: .uploaded,
            createdAt: details.createdAt
        )
    }
}
