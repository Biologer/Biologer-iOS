import Foundation

protocol FindingUploadRepository {
    func upload(id: UUID) async throws
}
