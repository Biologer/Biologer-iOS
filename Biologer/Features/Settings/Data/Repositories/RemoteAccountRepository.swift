import Foundation

final class RemoteAccountRepository: AccountRepository {
    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage

    init(client: APIClientProtocol, environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }

    func loadCurrentUser() async throws(APIError) -> UserDataResponse {
        do {
            let endpoint = GetProfileEndpoint(host: try environmentHost())
            return try await client.send(endpoint)
        } catch let error as APIError {
            throw error
        } catch let error as APIClientError {
            throw error.asAPIError()
        } catch {
            throw APIError(description: error.localizedDescription)
        }
    }

    func deleteCurrentUser(userID: Int, deleteObservations: Bool) async throws(APIError) {
        do {
            let endpoint = DeleteAccountEndpoint(
                host: try environmentHost(),
                userID: userID,
                deleteObservations: deleteObservations
            )
            _ = try await client.send(endpoint)
        } catch let error as APIError {
            throw error
        } catch let error as APIClientError {
            throw error.asAPIError()
        } catch {
            throw APIError(description: error.localizedDescription)
        }
    }

    private func environmentHost() throws(APIError) -> String {
        guard let environment = environmentStorage.getEnvironment() else {
            throw APIError(description: ErrorConstant.environmentNotSelected)
        }
        return environment.host
    }
}
