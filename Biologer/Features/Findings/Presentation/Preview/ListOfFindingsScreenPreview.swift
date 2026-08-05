import SwiftUI
import UIKit

struct ListOfFindingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            makeScreen(findings: previewFindings)
                .previewDisplayName("Findings ")

            makeScreen(findings: previewFindings)
                .preferredColorScheme(.dark)
                .previewDisplayName("Findings  - Dark")

            makeScreen(findings: [])
                .previewDisplayName("Findings  - Empty")
        }
    }

    private static func makeScreen(findings: [FindingSummary]) -> some View {
        let repository = PreviewFindingsRepository(findings: findings)
        let useCases = FindingsUseCases(
            getFindings: DefaultGetFindingsUseCase(repository: repository),
            deleteFinding: DefaultDeleteFindingUseCase(repository: repository),
            deleteFindings: DefaultDeleteFindingsUseCase(repository: repository),
            deleteAllFindings: DefaultDeleteAllFindingsUseCase(repository: repository)
        )
        let viewModel = ListOfFindingsViewModel(
            useCases: useCases,
            onAddFinding: {},
            uploadFindings: PreviewUploadFindingsUseCase(),
            checkSubmissionAccess: PreviewFindingSubmissionAccessUseCase()
        )

        return NavigationStack {
            ListOfFindingsScreen(viewModel: viewModel)
        }
    }

    private static let previewFindings = [
        FindingSummary(
            id: UUID(),
            taxonName: "Zerynthia polyxena",
            thumbnailData: thumbnailData(named: "intro1"),
            developmentStageName: "Larva",
            uploadStatus: .pending
        ),
        FindingSummary(
            id: UUID(),
            taxonName: "Salamandra salamandra",
            thumbnailData: thumbnailData(named: "intro2"),
            developmentStageName: "Adult",
            uploadStatus: .uploaded
        ),
        FindingSummary(
            id: UUID(),
            taxonName: "Alcedo atthis",
            thumbnailData: nil,
            developmentStageName: "Adult",
            uploadStatus: .pending
        ),
        FindingSummary(
            id: UUID(),
            taxonName: "Dendrocopos major",
            thumbnailData: thumbnailData(named: "intro3"),
            developmentStageName: "Juvenile",
            uploadStatus: .uploaded
        ),
        FindingSummary(
            id: UUID(),
            taxonName: "Pelophylax kl. esculentus",
            thumbnailData: thumbnailData(named: "taxon_background"),
            developmentStageName: "Tadpole",
            uploadStatus: .pending
        ),
        FindingSummary(
            id: UUID(),
            taxonName: "Papilio machaon",
            thumbnailData: thumbnailData(named: "intro4"),
            developmentStageName: "Pupa",
            uploadStatus: .uploaded
        ),
        FindingSummary(
            id: UUID(),
            taxonName: "Triturus carnifex macedonicus",
            thumbnailData: nil,
            developmentStageName: "Egg",
            uploadStatus: .pending
        ),
        FindingSummary(
            id: UUID(),
            taxonName: "Bombina variegata",
            thumbnailData: nil,
            developmentStageName: "Adult",
            uploadStatus: .uploaded
        ),
        FindingSummary(
            id: UUID(),
            taxonName: "Quercus robur",
            thumbnailData: nil,
            developmentStageName: "Flowering",
            uploadStatus: .pending
        ),
        FindingSummary(
            id: UUID(),
            taxonName: "",
            thumbnailData: nil,
            developmentStageName: "",
            uploadStatus: .pending
        )
    ]

    private static func thumbnailData(named imageName: String) -> Data? {
        UIImage(named: imageName)?.pngData()
    }
}

private final class PreviewFindingsRepository: FindingsRepository {
    private var findings: [FindingSummary]

    init(findings: [FindingSummary]) {
        self.findings = findings
    }

    func getAll() throws -> [FindingSummary] {
        findings
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
}
