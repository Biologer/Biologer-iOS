//
//  PostFindingService.swift
//  Biologer
//
//  Created by Nikola Popovic on 10.11.21..
//

import Foundation

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
