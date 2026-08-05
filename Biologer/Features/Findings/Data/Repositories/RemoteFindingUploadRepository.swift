import Foundation

protocol FindingRemoteUploadRepository {
    func uploadFinding(_ body: FindingRequestBody) async throws
    func uploadImage(_ imageData: Data) async throws -> String
}

final class RemoteFindingUploadRepository: FindingRemoteUploadRepository {
    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage

    init(client: APIClientProtocol, environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }

    func uploadFinding(_ body: FindingRequestBody) async throws {
        guard let environment = environmentStorage.getEnvironment() else {
            throw APIError(description: ErrorConstant.environmentNotSelected)
        }

        do {
            _ = try await client.send(
                UploadFindingEndpoint(host: environment.host, findingBody: body)
            )
        } catch let error as APIClientError {
            throw error.asAPIError()
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError(description: error.localizedDescription)
        }
    }

    func uploadImage(_ imageData: Data) async throws -> String {
        guard let environment = environmentStorage.getEnvironment() else {
            throw APIError(description: ErrorConstant.environmentNotSelected)
        }

        do {
            let response = try await client.send(
                UploadFindingImageEndpoint(
                    host: environment.host,
                    imageData: imageData
                )
            )
            return response.file ?? ""
        } catch let error as APIClientError {
            throw error.asAPIError()
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError(description: error.localizedDescription)
        }
    }
}
