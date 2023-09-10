//
//  TaxonService.swift
//  Biologer
//
//  Created by Nikola Popovic on 1.10.21..
//

import Foundation

public protocol TaxonService {
    typealias Result = Swift.Result<TaxonDataResponse, APIError>
    func getTaxons(currentPage: Int,
                   perPage: Int,
                   updatedAfter: Int64,
                   completion: @escaping (Result) -> Void)
}

public final class RemoteTaxonService: TaxonService {
    public typealias Result = Swift.Result<TaxonDataResponse, APIError>
    
    private let client: HTTPClient
    private let environmentStorage: EnvironmentStorage
    
    public init(client: HTTPClient,
                environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }
    
    public func getTaxons(currentPage: Int,
                          perPage: Int,
                          updatedAfter: Int64,
                          completion: @escaping (Result) -> Void) {
        if let env = environmentStorage.getEnvironment() {
            
            var queryParameters: [URLQueryItem] = [URLQueryItem]()
            queryParameters.append(URLQueryItem(name: "page",value: String(currentPage)))
            queryParameters.append(URLQueryItem(name: "per_page",value: String(perPage)))
            queryParameters.append(URLQueryItem(name: "updated_after",value: String(updatedAfter)))
            queryParameters.append(URLQueryItem(name: "withGroupsIds",value: String(false)))
            queryParameters.append(URLQueryItem(name: "ungrouped",value: String(updatedAfter)))
            
            let request = try! TaxonRequest(host: env.host, queryParameters: queryParameters).asURLRequest()
            client.perform(from: request) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(APIError(description: error.localizedDescription)))
                case .success(let result):
                    if result.1.statusCode == 200, let response = try? JSONDecoder().decode(TaxonDataResponse.self,
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
    
    private class TaxonRequest: APIRequest {
        
        var method: HTTPMethod = .get
        
        var host: String
        
        var path: String = APIConstants.taxonPath
        
        var queryParameters: [URLQueryItem]? = nil
        
        var body: Data?
        
        var headers: HTTPHeaders?
        
        init(host: String, queryParameters: [URLQueryItem]) {
            var headers = HTTPHeaders()
            headers.add(name: HTTPHeaderName.contentType, value: APIConstants.applicationJson)
            headers.add(name: HTTPHeaderName.acceept, value: APIConstants.applicationJson)
            self.headers = headers
            self.host = host
            self.queryParameters = queryParameters
        }
    }
}

