//
//  ForgotPasswordService.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public protocol ForgotPasswordService {
    typealias Result = Swift.Result<ForgotPasswordResponse, Error>
    func loadSearch(onCompletion: @escaping (Result) -> Void)
}

public final class RemoteForgotPasswordService: ForgotPasswordService {
    
    public typealias Result = Swift.Result<ForgotPasswordResponse, Error>
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func loadSearch(onCompletion: @escaping (Result) -> Void) {
        
    }
}
