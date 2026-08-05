import Foundation

protocol ObservationRepository {
    func getObservationTypes() async throws(SettingsDataFailure) -> ObservationDataResponse
    func synchronizeObservationTypes() async throws(SettingsDataFailure)
    func hasStoredObservationTypes() -> Bool
}
