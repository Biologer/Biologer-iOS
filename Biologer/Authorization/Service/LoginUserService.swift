//
//  LoginUserService.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public protocol LoginUserService {
    typealias Result = Swift.Result<LoginUserResponse, Error>
    func loadSearch(email: String, password: String, onCompletion: @escaping (Result) -> Void)
}

public final class RemoteLoginUserService: LoginUserService {
    
    public typealias Result = Swift.Result<LoginUserResponse, Error>
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func loadSearch(email: String,
                           password: String,
                           onCompletion: @escaping (Result) -> Void) {
        
    }
}
