//
//  LoginUserService.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public protocol LoginUserService {
    typealias Result = Swift.Result<LoginUserResponse, APIError>
    func login(email: String, password: String, completion: @escaping (Result) -> Void)
}

public final class RemoteLoginUserService: LoginUserService {
    
    public typealias Result = Swift.Result<LoginUserResponse, APIError>
    
    private let client: HTTPClient
    private let environmentStorage: EnvironmentStorage
    
    public init(client: HTTPClient,
                environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }
    
    public func login(email: String,
                           password: String,
                           completion: @escaping (Result) -> Void) {
        if let env = environmentStorage.getEnvironment() {
            let request = try! LoginUserRequest(email: email,
                                                password: password,
                                                host: env.host,
                                                cliendId: env.clientId,
                                                clientSecret: env.clientSecret).asURLRequest()
            client.perform(from: request) { result in
                switch result {
                case .failure(let error):
                    if NoInternetConnectionValidator.noInternetConnection(errorCode: (error as NSError).code) {
                        completion(.failure(APIError(title: ErrorConstant.noInternetConnectionTitle,
                                                     description: ErrorConstant.noInternetConnectionDescription,
                                                     isInternetConnectionAvailable: false)))
                    } else {
                        completion(.failure(APIError(description: error.localizedDescription)))
                    }
                case .success(let result):
                    if result.1.statusCode == 200, let response = try? JSONDecoder().decode(LoginUserResponse.self,
                                                                                    from: result.0) {
                        completion(.success(response))
                    } else {
                        if let response = try? JSONDecoder().decode(APIErrorResponse.self,from: result.0) {
                            completion(.failure(APIError(title: response.error, description: response.error_description)))
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
    
    private class LoginUserRequest: APIRequest {
        
        var method: HTTPMethod = .post
        
        var host: String = ""
        
        var path: String = APIConstants.loginUserPath
        
        var queryParameters: [URLQueryItem]? = nil
        
        var body: Data?
        
        var headers: HTTPHeaders?
        
        init(email: String, password: String, host: String, cliendId: String, clientSecret: String) {
            var headers = HTTPHeaders()
            headers.add(name: HTTPHeaderName.contentType, value: APIConstants.applicationJson)
            headers.add(name: HTTPHeaderName.acceept, value: APIConstants.applicationJson)
            self.headers = headers
            self.host = host
            let requestBody = LoginRequestModel(username: email,
                                                password: password,
                                                scope: APIConstants.scope,
                                                client_secret: clientSecret,
                                                client_id: cliendId,
                                                grant_type: APIConstants.grantType)
            let json = try! JSONEncoder().encode(requestBody)
            body = json
        }
    }
    
    private struct LoginRequestModel: Codable {
        let username: String
        let password: String
        let scope: String
        let client_secret: String
        let client_id: String
        let grant_type: String
    }
}
