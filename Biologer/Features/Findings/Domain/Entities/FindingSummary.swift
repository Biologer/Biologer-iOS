import Foundation

struct FindingSummary: Identifiable, Equatable {
    let id: UUID
    let taxonName: String
    let thumbnailData: Data?
    let developmentStageName: String
    let uploadStatus: FindingUploadStatus
}

enum FindingUploadStatus: Equatable {
    case pending
    case uploaded
}
