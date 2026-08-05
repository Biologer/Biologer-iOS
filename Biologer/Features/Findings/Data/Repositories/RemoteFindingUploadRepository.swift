import Foundation

protocol FindingRemoteUploadRepository {
    func uploadFinding(_ body: FindingRequestBody) async throws(FindingUploadFailure)
    func uploadImage(_ imageData: Data) async throws(FindingUploadFailure) -> String
}

final class RemoteFindingUploadRepository: FindingRemoteUploadRepository {
    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage

    init(client: APIClientProtocol, environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }

    func uploadFinding(_ body: FindingRequestBody) async throws(FindingUploadFailure) {
        guard let environment = environmentStorage.getEnvironment() else {
            throw FindingUploadFailure(message: "API.lb.envError".localized)
        }

        do {
            _ = try await client.send(
                UploadFindingEndpoint(host: environment.host, findingBody: body)
            )
        } catch let error as APIClientError {
            throw FindingUploadFailure(message: error.failureDetails.message)
        } catch {
            throw FindingUploadFailure(message: error.localizedDescription)
        }
    }

    func uploadImage(_ imageData: Data) async throws(FindingUploadFailure) -> String {
        guard let environment = environmentStorage.getEnvironment() else {
            throw FindingUploadFailure(message: "API.lb.envError".localized)
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
            throw FindingUploadFailure(message: error.failureDetails.message)
        } catch {
            throw FindingUploadFailure(message: error.localizedDescription)
        }
    }
}
