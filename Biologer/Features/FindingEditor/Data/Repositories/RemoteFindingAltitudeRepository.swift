import Foundation

final class RemoteFindingAltitudeRepository: FindingAltitudeRepository {
    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage

    init(client: APIClientProtocol, environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }

    func altitude(latitude: Double, longitude: Double) async throws -> Double {
        guard let environment = environmentStorage.getEnvironment() else {
            throw APIError(description: ErrorConstant.environmentNotSelected)
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
        } catch let error as APIClientError {
            throw error.asAPIError()
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError(description: error.localizedDescription)
        }
    }
}
