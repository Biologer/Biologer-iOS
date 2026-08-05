import Foundation

protocol ObservationRepository {
    func getObservationTypes() async throws(APIError) -> ObservationDataResponse
}
