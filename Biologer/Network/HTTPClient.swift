//
//  HTTPClient.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
    func resume()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @discardableResult
    func perform(from request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
