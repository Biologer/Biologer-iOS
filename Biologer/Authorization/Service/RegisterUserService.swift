//
//  AuthorizationService.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public protocol RegisterUserService {
    typealias Result = Swift.Result<RegisterUserResponse, Error>
    func loadSearch(user: User, completion: @escaping (Result) -> Void)
}

public enum CreateUserServiceError: LocalizedError {
    case parsingError
    
    public var errorDescription: String? {
        switch self {
        case .parsingError:
            return "Could not parse user response"
        }
    }
}

public final class RemoteRegisterUserService: RegisterUserService {
    
    public typealias Result = Swift.Result<RegisterUserResponse, Error>
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func loadSearch(user: User, completion: @escaping (Result) -> Void) {
        let request = try! CreateUserRequest(user: user).asURLRequest()
        client.perform(from: request) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let result):
                if result.1.statusCode == 200, let response = try? JSONDecoder().decode(RegisterUserResponse.self,
                                                                                from: result.0) {
                    completion(.success(response))
                } else {
                    completion(.failure(CreateUserServiceError.parsingError))
                }
            }
        }
    }
    
    private class CreateUserRequest: APIRequest {
        
        var method: HTTPMethod = .post
        
        var host: String = ""
        
        var path: String = ""
        
        var queryParameters: [URLQueryItem]? = nil
        
        var body: Data?
        
        var headers: HTTPHeaders?
        
        init(user: User) {
            var headers = HTTPHeaders()
            headers.add(name: HTTPHeaderName.contentType, value: "application/json; charset=utf-8")
            self.headers = headers
            
            let requestBody = RemoteRegisterRequestModel(first_name: user.username,
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
        let first_name: String
        let last_name: String
        let data_license: Int
        let image_license: Int
        let institution: String?
        let email: String
        let password: String
    }
}
