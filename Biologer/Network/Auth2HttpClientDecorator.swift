//
//  Auth2HttpClientDecorator.swift
//  Biologer
//
//  Created by Nikola Popovic on 20.9.21..
//

import Foundation

public class Auth2HttpClientDecorator: HTTPClient {
    
    public typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    private let decoratee: HTTPClient
    private let tokenStorage: TokenStorage
    
    init(decoratee: HTTPClient, tokenStorage: TokenStorage) {
        self.decoratee = decoratee
        self.tokenStorage = tokenStorage
    }
    
    public func perform(from request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask {
        var mutableRequest = request
        if let token = tokenStorage.getToken(), !token.accessToken.isEmpty {
            let accessToken = token.accessToken
            mutableRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: HTTPHeaderName.authorization.description)
        }
        return decoratee.perform(from: mutableRequest, completion: completion)
    }
}
