//
//  ProfileService.swift
//  Biologer
//
//  Created by Nikola Popovic on 20.9.21..
//

import Foundation

public protocol ProfileService {
    typealias ProfileResult = Swift.Result<UserDataResponse, APIError>
    typealias DeletionResult = Swift.Result<Void, APIError>
    
    func getMyProfile(completion: @escaping (ProfileResult) -> Void)
    func deleteUser(userID: Int, deleteObservations: Bool, completion: @escaping (DeletionResult) -> Void)
}

public class RemoteProfileService: ProfileService {
    
    public typealias ProfileResult = Swift.Result<UserDataResponse, APIError>
    public typealias DeletionResult = Swift.Result<Void, APIError>
    
    private let client: HTTPClient
    private let environmentStorage: EnvironmentStorage
    
    public init(client: HTTPClient,
                environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }
    
    public func getMyProfile(completion: @escaping (ProfileResult) -> Void) {
        if let env = environmentStorage.getEnvironment() {
            let request = try! MyProfileRequest(host: env.host).asURLRequest()
            client.perform(from: request) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(APIError(description: error.localizedDescription)))
                case .success(let result):
                    if result.1.statusCode == 200, let response = try? JSONDecoder().decode(UserDataResponse.self, from: result.0) {
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
    
    public func deleteUser(userID: Int, deleteObservations: Bool, completion: @escaping (DeletionResult) -> Void) {
        if let env = environmentStorage.getEnvironment() {
            let request = try! DeleteUserRequest(host: env.host, userID: userID, deleteObservations: deleteObservations).asURLRequest()
            client.perform(from: request) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(APIError(description: error.localizedDescription)))
                case .success(let response):
                    if response.1.statusCode == 204 {
                        completion(.success(()))
                    } else {
                        completion(.failure(APIError(description: ErrorConstant.accountDeletionFailed)))
                    }
                }
            }
        } else {
            completion(.failure(APIError(description: ErrorConstant.environmentNotSelected)))
        }
    }
    
    private class MyProfileRequest: APIRequest {
        
        var method: HTTPMethod = .get
        
        var host: String
        
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
    
    private class DeleteUserRequest: APIRequest {
        
        var method: HTTPMethod = .delete
        
        var host: String
        
        var path: String = APIConstants.deleteUserPath // Define the correct path in APIConstants
        
        var queryParameters: [URLQueryItem]?
        
        var body: Data? = nil
        
        var headers: HTTPHeaders?
        
        init(host: String, userID: Int, deleteObservations: Bool) {
            var headers = HTTPHeaders()
            headers.add(name: HTTPHeaderName.acceept, value: APIConstants.applicationJson)
            self.headers = headers
            self.host = host
            self.path = "\(APIConstants.deleteUserPath)/\(userID)"
            self.queryParameters = [URLQueryItem(name: "delete_observations", value: deleteObservations ? "1" : "0")]
        }
    }
}
