import Foundation

final class RemoteFindingAltitudeRepository: FindingAltitudeRepository {
    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage

    init(client: APIClientProtocol, environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }

    func altitude(
        latitude: Double,
        longitude: Double
    ) async throws(FindingAltitudeRepositoryError) -> Double {
        guard let environment = environmentStorage.getEnvironment() else {
            throw .environmentUnavailable
        }

        do {
            let response = try await client.send(
                GetAltitudeEndpoint(
                    host: environment.host,
                    latitude: latitude,
                    longitude: longitude
                )
            )
            return Double(response.elevation)
        } catch {
            throw .altitudeUnavailable
        }
    }
}
