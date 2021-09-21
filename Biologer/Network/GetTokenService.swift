//
//  GetTokenService.swift
//  Biologer
//
//  Created by Nikola Popovic on 21.9.21..
//

import Foundation

public protocol GetTokenService {
    typealias Result = Swift.Result<Token, APIError>
    func getToken(refreshToken: String, completion: @escaping (Result) -> Void)
}

public final class RemoteGetTokenService: GetTokenService, CodableParser {
    
    public typealias Result = Swift.Result<Token, APIError>
    
    public enum Error: LocalizedError {
        case invalidData
        
        public var errorDescription: String? {
            switch self {
            case .invalidData:
                return "Could not parse Token response"
            }
        }
    }
    
    private struct RemoteToken: Codable {
        let refresh_token: String
        let access_token: String
    }
    
    private let client: HTTPClient
    private let environmentStorage: EnvironmentStorage
    
    public init(client: HTTPClient,
                environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }
    
    public func getToken(refreshToken: String, completion: @escaping (Result) -> Void) {
        
        if let env = environmentStorage.getEnvironment() {
            let request = try! GetTokenRequest(host: env.host,
                                               clientId: env.clientId,
                                               clientSecret: env.clientSecret,
                                               refreshToken: refreshToken).asURLRequest()
            client.perform(from: request) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(APIError(description: error.localizedDescription)))
                case .success(let result):
                    if result.1.statusCode == 200, let response = try? JSONDecoder().decode(Token.self,
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
    
    private func map(result: (Data, HTTPURLResponse)) -> Token? {
        guard result.1.statusCode == 200, let response: RemoteToken = self.parse(from: result.0) else {
            return nil
        }
        return Token(accessToken: response.access_token, refreshToken: response.refresh_token)
    }
    
    private struct GetTokenRequest: APIRequest {
        
        let method: HTTPMethod = .post
        let host: String
        var path: String = APIConstants.loginUserPath
        let queryParameters: [URLQueryItem]? = nil
        var body: Data? = nil
        var headers: HTTPHeaders? = nil
        
        init(host: String,
             clientId: String,
             clientSecret: String,
             refreshToken: String) {
            var headers = HTTPHeaders()
            headers.add(name: HTTPHeaderName.contentType, value: APIConstants.applicationJson)
            headers.add(name: HTTPHeaderName.acceept, value: APIConstants.applicationJson)
            self.headers = headers
            let body = GetTokenBody(grant_type: APIConstants.grantType,
                                    client_id: clientId,
                                    client_secret: clientSecret,
                                    refresh_token: refreshToken,
                                    scope: APIConstants.scope)
            let json = try! JSONEncoder().encode(body)
            self.body = json
            self.host = host
        }
    }
    
    private struct GetTokenBody: Codable {
        let grant_type: String
        let client_id: String
        let client_secret: String
        let refresh_token: String
        let scope: String
    }
}

