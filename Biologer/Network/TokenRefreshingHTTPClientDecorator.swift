//
//  TokenRefreshingHTTPClientDecorator.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.9.21..
//

import Foundation

public final class TokenRefreshingHTTPClientDecorator: HTTPClient, CodableParser {
    
    public typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    public static let accessTokenExpiredCode = 401
    
    private let decoratee: HTTPClient
    private let getTokenService: GetTokenService
    private let tokenStorage: TokenStorage
    
    private var completion: ((Result) -> Void)?
    
    public var onLogout: (() -> Void)?
    
    public init(decoratee: HTTPClient,
                getTokenService: GetTokenService,
                tokenStorage: TokenStorage) {
        self.decoratee = decoratee
        self.getTokenService = getTokenService
        self.tokenStorage = tokenStorage
    }
    
    public func perform(from request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask {
        self.completion = completion
        return decoratee.perform(from: request) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response):
                if response.1.statusCode == TokenRefreshingHTTPClientDecorator.accessTokenExpiredCode && self.tokenStorage.getToken() != nil {
                    let token = self.tokenStorage.getToken()!
                    self.getToken(forRefreshToken: token.refreshToken, request: request, completion: completion)
                } else {
                    completion(result)
                }
            }
        }
    }
    
    private func replaceToken(forRequest request: URLRequest, token: Token) -> URLRequest {
        var newRequest = request
        newRequest.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaderName.authorization.description)
        return newRequest
    }
    
    private func getToken(forRefreshToken token: String, request: URLRequest, completion: @escaping (Result) -> Void) {
        self.getTokenService.getToken(refreshToken: token) { [weak self](result) in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.tokenStorage.saveToken(token: token)
                let request = self.replaceToken(forRequest: request, token: token)
                
                let task = self.decoratee.perform(from: request) { result in
                    self.completion?(result)
                }
                task.resume()
            case .failure(_):
                self.onLogout?()
            }
        }
    }
}
