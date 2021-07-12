//
//  LoginUserService.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public protocol LoginUserService {
    typealias Result = Swift.Result<LoginUserResponse, Error>
    func loadSearch(email: String, password: String, completion: @escaping (Result) -> Void)
}

public enum LoginServiceError: LocalizedError {
    case parsingError
    
    public var errorDescription: String? {
        switch self {
        case .parsingError:
            return "Could not parse user response"
        }
    }
}


public final class RemoteLoginUserService: LoginUserService {
    
    public typealias Result = Swift.Result<LoginUserResponse, Error>
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func loadSearch(email: String,
                           password: String,
                           completion: @escaping (Result) -> Void) {
        let request = try! LoginUserRequest(email: email, password: password).asURLRequest()
        client.perform(from: request) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let result):
                if result.1.statusCode == 200, let response = try? JSONDecoder().decode(LoginUserResponse.self,
                                                                                from: result.0) {
                    completion(.success(response))
                } else {
                    completion(.failure(LoginServiceError.parsingError))
                }
            }
        }
    }
    
    private class LoginUserRequest: APIRequest {
        
        var method: HTTPMethod = .post
        
        var host: String = ""
        
        var path: String = ""
        
        var queryParameters: [URLQueryItem]? = nil
        
        var body: Data?
        
        var headers: HTTPHeaders?
        
        init(email: String, password: String) {
            var headers = HTTPHeaders()
            headers.add(name: HTTPHeaderName.contentType, value: "application/json; charset=utf-8")
            self.headers = headers
            
            let requestBody = LoginRequestModel(username: email, password: password)
            let json = try! JSONEncoder().encode(requestBody)
            body = json
        }
    }
    
    private struct LoginRequestModel: Codable {
        let username: String
        let password: String
    }
}
