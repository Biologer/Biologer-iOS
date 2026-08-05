//
//  PostFindingService.swift
//  Biologer
//
//  Created by Nikola Popovic on 10.11.21..
//

import Foundation

public struct FindingResponse: Codable {
    
}

public struct FindingRequestBody: Codable {
    let atlasCode: Int?
    let accuracy: Int?
    let data_license: String?
    let day: String?
    let elevation: Int?
    let found_dead: Int?
    let found_dead_note: String?
    let found_on: String?
    let habitat: String?
    let latitude: Double?
    let longitude: Double?
    let location: String?
    let month: String?
    let note: String?
    let number: Int?
    let observation_types_ids: [Int]?
    let photos: [FindingPhotoRequestBody]?
    let project: String?
    let sex: String?
    let stage_id: Int?
    let taxon_id: Int?
    let taxon_suggestion: String?
    let time: String?
    let year: String?
}

public struct FindingPhotoRequestBody: Codable {
    let license: String
    let path: String
}

public protocol PostFindingService {
    typealias Result = Swift.Result<FindingResponse, APIError>
    func uploadFinding(findingBody: FindingRequestBody,completion: @escaping (Result) -> Void)
}

public final class RemotePostFindingService: PostFindingService {
    
    public typealias Result = Swift.Result<FindingResponse, APIError>
    
    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage
    
    public init(client: APIClientProtocol,
                environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }
    
    public func uploadFinding(findingBody: FindingRequestBody, completion: @escaping (Result) -> Void) {
        guard let env = environmentStorage.getEnvironment() else {
            completion(.failure(APIError(description: ErrorConstant.environmentNotSelected)))
            return
        }

        Task {
            do {
                let endpoint = UploadFindingEndpoint(host: env.host, findingBody: findingBody)
                completion(.success(try await client.send(endpoint)))
            } catch let error as APIClientError {
                completion(.failure(error.asAPIError()))
            } catch {
                completion(.failure(APIError(description: error.localizedDescription)))
            }
        }
    }
}
