//
//  AuthorizationService.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public protocol RegisterUserService {
    typealias Result = Swift.Result<RegisterUserResponse, APIError>
    func loadSearch(user: User, completion: @escaping (Result) -> Void)
}

public enum CreateUserServiceError: LocalizedError {
    case parsingError
    case noEnvironment
    
    public var errorDescription: String? {
        switch self {
        case .parsingError:
            return "Could not parse user response"
        case .noEnvironment:
            return "Please select environment"
        }
    }
}

public final class RemoteRegisterUserService: RegisterUserService {
    
    public typealias Result = Swift.Result<RegisterUserResponse, APIError>
    
    private let client: HTTPClient
    private let environmentStorage: EnvironmentStorage
    
    public init(client: HTTPClient,
                environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }
    
    public func loadSearch(user: User, completion: @escaping (Result) -> Void) {
        if let env = environmentStorage.getEnvironment() {
            let request = try! CreateUserRequest(user: user,
                                                 host: env.host,
                                                 clientId: env.clientId,
                                                 clientSecret: env.clientSecret).asURLRequest()
            client.perform(from: request) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(APIError(description: error.localizedDescription)))
                case .success(let result):
                    if result.1.statusCode == 200, let response = try? JSONDecoder().decode(RegisterUserResponse.self,
                                                                                    from: result.0) {
                        completion(.success(response))
                    } else {
                        if let response = try? JSONDecoder().decode(RegisterErrorResponse.self,from: result.0) {
                            completion(.failure(APIError(title: response.message, description: "")))
                        } else {
                            completion(.failure(APIError(description: parsingErrorConstant)))
                        }
                    }
                }
            }
        } else {
            completion(.failure(APIError(description: environmentNotSelected)))
        }
    }
    
    private class CreateUserRequest: APIRequest {
        
        var method: HTTPMethod = .post
        
        var host: String = ""
        
        var path: String = "/api/register"
        
        var queryParameters: [URLQueryItem]? = nil
        
        var body: Data?
        
        var headers: HTTPHeaders?
        
        init(user: User,
             host: String,
             clientId: String,
             clientSecret: String) {
            var headers = HTTPHeaders()
            headers.add(name: HTTPHeaderName.contentType, value: "application/json")
            headers.add(name: HTTPHeaderName.acceept, value: "application/json")
            self.headers = headers
            self.host = host
            let requestBody = RemoteRegisterRequestModel(client_id: clientId,
                                                         client_secret: clientSecret,
                                                         first_name: user.username,
                                                         last_name: user.lastname,
                                                         data_license: user.dataLicense.id,
                                                         image_license: user.imageLicense.id,
                                                         institution: user.insitution,
                                                         email: user.email,
                                                         password: user.password)
            let json = try! JSONEncoder().encode(requestBody)
            body = json
        }
    }
    
    private struct RemoteRegisterRequestModel: Codable {
        let client_id: String
        let client_secret: String
        let first_name: String
        let last_name: String
        let data_license: Int
        let image_license: Int
        let institution: String?
        let email: String
        let password: String
    }
    
    private struct RegisterErrorResponse: Codable {
        let message: String
    }
}
