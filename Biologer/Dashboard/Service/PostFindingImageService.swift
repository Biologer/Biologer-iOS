import UIKit

public struct FindingImageResponse: Codable {
    let file: String?
}

public protocol PostFindingImageService {
    typealias Result = Swift.Result<FindingImageResponse, APIError>
    func uploadFindingImages(taxonImages: TaxonImage, completion: @escaping (Result) -> Void)
}

public final class RemotePostFindingImageService: PostFindingImageService {
    public typealias Result = Swift.Result<FindingImageResponse, APIError>

    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage

    public init(client: APIClientProtocol, environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }

    public func uploadFindingImages(taxonImages: TaxonImage, completion: @escaping (Result) -> Void) {
        guard let environment = environmentStorage.getEnvironment() else {
            completion(.failure(APIError(description: ErrorConstant.environmentNotSelected)))
            return
        }

        guard let endpoint = UploadFindingImageEndpoint(host: environment.host, taxonImage: taxonImages) else {
            completion(.failure(APIError(description: ErrorConstant.parsingErrorConstant)))
            return
        }

        Task {
            do {
                completion(.success(try await client.send(endpoint)))
            } catch let error as APIClientError {
                completion(.failure(error.asAPIError()))
            } catch {
                completion(.failure(APIError(description: error.localizedDescription)))
            }
        }
    }
}
