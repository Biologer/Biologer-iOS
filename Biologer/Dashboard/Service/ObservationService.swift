//
//  ObservationService.swift
//  Biologer
//
//  Created by Nikola Popovic on 21.9.21..
//

import Foundation

public protocol ObservationService {
    typealias Result = Swift.Result<ObservationDataResponse, APIError>
    func getObservationTypes(completion: @escaping (Result) -> Void)
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
    
    public func getObservationTypes(completion: @escaping (Result) -> Void) {
        if let env = environmentStorage.getEnvironment() {
            let request = try! ObservationRequest(host: env.host).asURLRequest()
            client.perform(from: request) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(APIError(description: error.localizedDescription)))
                case .success(let result):
                    if result.1.statusCode == 200, let response = try? JSONDecoder().decode(ObservationDataResponse.self, from: result.0) {
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
        
        var host: String
        
        var path: String = APIConstants.observationTypesPath
        
        var queryParameters: [URLQueryItem]? = nil
        
        var body: Data?
        
        var headers: HTTPHeaders?
        
        init(host: String) {
            var headers = HTTPHeaders()
            headers.add(name: HTTPHeaderName.contentType, value: APIConstants.applicationJson)
            headers.add(name: HTTPHeaderName.acceept, value: APIConstants.applicationJson)
            self.headers = headers
            self.host = host
            
            let time = fetchLastUpdatedTime()
            self.queryParameters = [URLQueryItem(name: APIConstants.updatedAfter, value: "\(time)")]
            
            saveLastUpdatedTime()
        }
        
        private func fetchLastUpdatedTime() -> Int {
            return UserDefaults.standard.integer(forKey: APIConstants.updatedAfter)
        }
        
        private func saveLastUpdatedTime() {
            let timestamp = Int(Date().timeIntervalSince1970)
            UserDefaults.standard.set(timestamp, forKey: APIConstants.updatedAfter)
            UserDefaults.standard.synchronize()
        }
    }
}
