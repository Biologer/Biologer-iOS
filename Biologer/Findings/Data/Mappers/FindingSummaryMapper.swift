import Foundation

enum FindingSummaryMapper {
    static func map(_ finding: DBFinding) -> FindingSummary {
        FindingSummary(
            id: finding.id,
            taxonName: finding.taxon?.name ?? "",
            thumbnailData: thumbnailData(from: finding),
            developmentStageName: finding.devStage?.name ?? "",
            uploadStatus: finding.isUploaded ? .uploaded : .pending
        )
    }

    private static func thumbnailData(from finding: DBFinding) -> Data? {
        guard let data = finding.images.first?.image, !data.isEmpty else {
            return nil
        }
        return data
    }
}
