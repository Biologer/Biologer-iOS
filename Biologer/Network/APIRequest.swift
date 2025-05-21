//
//  APIRequest.swift
//  Biologer
//
//  Created by Nikola Popovic on 12.7.21..
//

import Foundation

protocol APIRequest {
    
    var method: HTTPMethod { get }
    var host: String { get }
    var path: String { get }
    var queryParameters: [URLQueryItem]? { get }
    var body: Data? { get }
    var headers: HTTPHeaders? { get set }
}

extension APIRequest {
    func asURLRequest() throws -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryParameters
        let url = try urlComponents.asURL()
        var urlRequest = URLRequest(url: url)
        urlRequest.url = try urlComponents.asURL()
        urlRequest.allHTTPHeaderFields = headers?.dictionary
        urlRequest.httpBody = body
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
}

enum APIRequestError: Error {
    case invalidRequestStructure
}

struct HTTPHeaders {
    
    fileprivate var dictionary: [String: String] = [:]
    
    subscript(index: HTTPHeaderName) -> String? {
        return dictionary[String(describing: index)]
    }
    
    mutating func add(name: HTTPHeaderName, value: String) {
        dictionary[String(describing: name)] = value
    }
    
    mutating func remove(name: HTTPHeaderName) {
        dictionary.removeValue(forKey: String(describing: name))
    }
    
}

struct HTTPHeaderName: CustomStringConvertible {
    
    private let stringValue: String
    var description: String {
        return stringValue
    }
    
    private init(string: String) {
        self.stringValue = string
    }
    
    static let authorization = HTTPHeaderName(string: "Authorization")
    static let contentType = HTTPHeaderName(string: "Content-Type")
    static let acceept  = HTTPHeaderName(string: "accept")
    static let userAgent = HTTPHeaderName(string: "User-Agent")
    static let accessToken = HTTPHeaderName(string: "access_token")
    
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

extension URLComponents {
    func asURL() throws -> URL {
        guard let url = url else { throw APIRequestError.invalidRequestStructure }
        return url
    }
}
