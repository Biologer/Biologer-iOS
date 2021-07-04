//
//  AuthorizationService.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public protocol RegisterUserService {
    typealias Result = Swift.Result<RegisterUserResponse, Error>
    func loadSearch(onCompletion: @escaping (Result) -> Void)
}

public final class RemoteRegisterUserService: RegisterUserService {
    
    public typealias Result = Swift.Result<RegisterUserResponse, Error>
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func loadSearch(onCompletion: @escaping (Result) -> Void) {
        
    }
}
