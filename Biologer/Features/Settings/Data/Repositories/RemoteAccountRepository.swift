import Foundation

final class RemoteAccountRepository: AccountRepository {
    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage

    init(client: APIClientProtocol, environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }

    func loadCurrentUser() async throws(APIError) -> User {
        do {
            let endpoint = GetProfileEndpoint(host: try environmentHost())
            let response = try await client.send(endpoint)
            return User(response.data)
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

private extension User {
    convenience init(_ response: UserDataResponse.UserResponse) {
        self.init(
            id: response.id,
            firstName: response.first_name,
            lastName: response.last_name,
            email: response.email,
            fullName: response.full_name,
            isVerified: response.is_verified,
            settings: Settings(
                dataLicense: response.settings.data_license,
                imageLicense: response.settings.image_license,
                language: response.settings.language
            )
        )
    }
}
