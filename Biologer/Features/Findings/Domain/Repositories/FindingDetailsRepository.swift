import Foundation

protocol FindingDetailsRepository {
    func get(id: UUID) throws -> FindingDetails
}
