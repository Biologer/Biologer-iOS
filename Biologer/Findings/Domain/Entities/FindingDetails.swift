import Foundation

struct FindingDetails: Identifiable, Equatable {
    let id: UUID
    let taxonName: String
    let photos: [FindingPhoto]
    let developmentStageName: String?
    let atlasCodeName: String?
    let location: FindingDetailsLocation?
    let individuals: FindingDetailsIndividuals
    let observations: [String]
    let comment: String?
    let habitat: String?
    let foundOn: String?
    let foundDead: String?
    let uploadStatus: FindingUploadStatus
    let createdAt: Date
}

struct FindingPhoto: Equatable {
    let name: String
    let imageData: Data?
    let remoteURL: URL?
}

struct FindingDetailsLocation: Equatable {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let accuracy: Double
}

struct FindingDetailsIndividuals: Equatable {
    let total: Int?
    let male: Int?
    let female: Int?

    var isEmpty: Bool {
        total == nil && male == nil && female == nil
    }
}
