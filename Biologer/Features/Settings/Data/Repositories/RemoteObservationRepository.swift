import Foundation

final class RemoteObservationRepository: ObservationRepository {
    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage
    private let userDefaults: UserDefaults
    private let date: () -> Date

    init(
        client: APIClientProtocol,
        environmentStorage: EnvironmentStorage,
        userDefaults: UserDefaults = .standard,
        date: @escaping () -> Date = Date.init
    ) {
        self.client = client
        self.environmentStorage = environmentStorage
        self.userDefaults = userDefaults
        self.date = date
    }

    func getObservationTypes() async throws(SettingsDataFailure) -> ObservationDataResponse {
        do {
            guard let environment = environmentStorage.getEnvironment() else {
                throw SettingsDataFailure(message: "API.lb.envError".localized)
            }

            let updatedAfter = userDefaults.integer(forKey: APIConstants.updatedAfter)
            userDefaults.set(Int(date().timeIntervalSince1970), forKey: APIConstants.updatedAfter)
            let endpoint = ObservationTypesEndpoint(host: environment.host, updatedAfter: updatedAfter)
            return try await client.send(endpoint)
        } catch let error as SettingsDataFailure {
            throw error
        } catch let error as APIClientError {
            throw SettingsDataFailure(message: error.failureDetails.message)
        } catch {
            throw SettingsDataFailure(message: error.localizedDescription)
        }
    }

    func synchronizeObservationTypes() async throws(SettingsDataFailure) {
        let response = try await getObservationTypes()
        response.data.forEach {
            RealmManager.add(DBObservationMapper.mapForDB(observationResponse: $0))
        }
    }

    func hasStoredObservationTypes() -> Bool {
        !RealmManager.get(fromEntity: DBObservation.self).isEmpty
    }
}
