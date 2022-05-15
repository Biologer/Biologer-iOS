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
    
    private let client: HTTPClient
    private let environmentStorage: EnvironmentStorage
    
    public init(client: HTTPClient,
                environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }
    
    public func uploadFinding(findingBody: FindingRequestBody, completion: @escaping (Result) -> Void) {
        if let env = environmentStorage.getEnvironment() {
            let request = try! FindingRequest(host: env.host,
                                              findingBody: findingBody).asURLRequest()
            client.perform(from: request) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(APIError(description: error.localizedDescription)))
                case .success(let result):
                    if result.1.statusCode == 200 || result.1.statusCode == 201, let response = try? JSONDecoder().decode(FindingResponse.self,
                                                                                    from: result.0) {
                        completion(.success(response))
                    } else {
                        if let response = try? JSONDecoder().decode(APIErrorResponse.self,from: result.0) {
                            let errorDescription = response.errors?.first?.value
                            completion(.failure(APIError(title: response.message ?? "", description: errorDescription?.first ?? "")))
                        } else {
                            completion(.failure(APIError(description: ErrorConstant.parsingErrorConstant)))
                        }
                    }
                }
            }
        } else {
            completion(.failure(APIError(description: ErrorConstant.environmentNotSelected)))
        }
    }
    
    private struct APIErrorResponse: Codable {
        let message: String?
        let errors: [String: [String]]?
    }
    
    private class FindingRequest: APIRequest {
        
        var method: HTTPMethod = .post
        
        var host: String
        
        var path: String = APIConstants.uploadFindingPath
        
        var queryParameters: [URLQueryItem]? = nil
        
        var body: Data?
        
        var headers: HTTPHeaders?
        
        init(host: String, findingBody: FindingRequestBody) {
            var headers = HTTPHeaders()
            headers.add(name: HTTPHeaderName.contentType, value: APIConstants.applicationJson)
            headers.add(name: HTTPHeaderName.acceept, value: APIConstants.applicationJson)
            self.headers = headers
            self.host = host
            let json = try! JSONEncoder().encode(findingBody)
            body = json
        }
    }
}
