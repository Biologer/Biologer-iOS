import Foundation

final class RemoteFindingAltitudeRepository: FindingAltitudeRepository {
    private let client: APIClientProtocol
    private let environmentProvider: CurrentEnvironmentProviding

    init(
        client: APIClientProtocol,
        environmentProvider: CurrentEnvironmentProviding
    ) {
        self.client = client
        self.environmentProvider = environmentProvider
    }

    func altitude(
        latitude: Double,
        longitude: Double
    ) async throws(FindingAltitudeRepositoryError) -> Double {
        guard let environment = environmentProvider.currentEnvironment() else {
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
