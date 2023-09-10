//
//  MainQueueHTTPClientDecorator.swift
//  Biologer
//
//  Created by Nikola Popovic on 10.9.23..
//

import Foundation

public final class MainQueueHTTPClientDecorator: HTTPClient {
    
    public typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    private let decoratee: HTTPClient
    
    public init(decoratee: HTTPClient) {
        self.decoratee = decoratee
    }
    
    public func perform(from request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask {
        return decoratee.perform(from: request) { (result) in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
