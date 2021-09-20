//
//  ProfileService.swift
//  Biologer
//
//  Created by Nikola Popovic on 20.9.21..
//

import Foundation

public protocol ProfileService {
    typealias Result = Swift.Result<UserDataResponse, APIError>
    func getMyProfile(completion: @escaping (Result) -> Void)
}

public class RemoteProfileService: ProfileService {
    
    public typealias Result = Swift.Result<UserDataResponse, APIError>
    
    private let client: HTTPClient
    private let environmentStorage: EnvironmentStorage
    
    public init(client: HTTPClient,
                environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }
    
    public func getMyProfile(completion: @escaping (Result) -> Void) {
        if let env = environmentStorage.getEnvironment() {
            let request = try! MyProfileRequest(host: env.host).asURLRequest()
            client.perform(from: request) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(APIError(description: error.localizedDescription)))
                case .success(let result):
                    if result.1.statusCode == 200, let response = try? JSONDecoder().decode(UserDataResponse.self,
                                                                                    from: result.0) {
                        completion(.success(response))
                    } else {
                        completion(.failure(APIError(description: ErrorConstant.parsingErrorConstant)))
                    }
                }
            }
        } else {
            completion(.failure(APIError(description: ErrorConstant.environmentNotSelected)))
        }
    }
    
    private class MyProfileRequest: APIRequest {
        
        var method: HTTPMethod = .get
        
        var host: String = ""
        
        var path: String = APIConstants.myProfilePath
        
        var queryParameters: [URLQueryItem]? = nil
        
        var body: Data?
        
        var headers: HTTPHeaders?
        
        init(host: String) {
            var headers = HTTPHeaders()
            headers.add(name: HTTPHeaderName.contentType, value: APIConstants.applicationJson)
            headers.add(name: HTTPHeaderName.acceept, value: APIConstants.applicationJson)
            self.headers = headers
            self.host = host
        }
    }
}
