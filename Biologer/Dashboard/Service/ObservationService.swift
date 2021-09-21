//
//  ObservationService.swift
//  Biologer
//
//  Created by Nikola Popovic on 21.9.21..
//

import Foundation

public protocol ObservationService {
    typealias Result = Swift.Result<ObservationDataResponse, APIError>
    func getObservation(completion: @escaping (Result) -> Void)
}

public final class RemoteObservationService: ObservationService {
    
    public typealias Result = Swift.Result<ObservationDataResponse, APIError>
    
    private let client: HTTPClient
    private let environmentStorage: EnvironmentStorage
    
    public init(client: HTTPClient,
                environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }
    
    public func getObservation(completion: @escaping (Result) -> Void) {
        if let env = environmentStorage.getEnvironment() {
            let request = try! ObservationRequest(host: env.host).asURLRequest()
            client.perform(from: request) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(APIError(description: error.localizedDescription)))
                case .success(let result):
                    if result.1.statusCode == 200, let response = try? JSONDecoder().decode(ObservationDataResponse.self,
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
    
    private class ObservationRequest: APIRequest {
        
        var method: HTTPMethod = .get
        
        var host: String = ""
        
        var path: String = APIConstants.observationsPath
        
        var queryParameters: [URLQueryItem]? = nil
        
        var body: Data?
        
        var headers: HTTPHeaders?
        
        init(host: String) {
            var headers = HTTPHeaders()
            headers.add(name: HTTPHeaderName.contentType, value: APIConstants.applicationJson)
            headers.add(name: HTTPHeaderName.acceept, value: APIConstants.applicationJson)
            self.headers = headers
            self.host = host
        }
    }
}
