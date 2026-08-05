import Foundation

protocol ObservationRepository {
    func getObservationTypes() async throws(APIError) -> ObservationDataResponse
    func synchronizeObservationTypes() async throws(APIError)
    func hasStoredObservationTypes() -> Bool
}
