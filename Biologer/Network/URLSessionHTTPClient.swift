//
//  URLSessionHTTPClient.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        
        func resume() {
            wrapped.resume()
        }
        
        var originalRequest: URLRequest? {
            return wrapped.originalRequest
        }
        
        var currentRequest: URLRequest? {
            return wrapped.currentRequest
        }
        
        let wrapped: URLSessionTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    public func perform(from request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: request) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
}

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
