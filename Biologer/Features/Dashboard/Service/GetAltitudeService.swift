//
//  GetAltitudeService.swift
//  Biologer
//
//  Created by Nikola Popovic on 1.12.21..
//

import Foundation

public protocol GetAltitudeService {
    typealias Result = Swift.Result<GetAlitutdeByLocationResponse, APIError>
    func getAltitude(latitude: Double,
                     longitude: Double,
                     completion: @escaping (Result) -> Void)
}

public class RemoteGetAltitudeService: GetAltitudeService {
    
    public typealias Result = Swift.Result<GetAlitutdeByLocationResponse, APIError>
    
    private let client: HTTPClient
    private let environmentStorage: EnvironmentStorage
    
    public init(client: HTTPClient,
                environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }
    
    public func getAltitude(latitude: Double,
                            longitude: Double,
                            completion: @escaping (Result) -> Void) {
        if let env = environmentStorage.getEnvironment() {
            let latitudeAdjusted = (Double(round(10 * latitude) / 10))
            let longitudeAdjusted = (Double(round(10 * longitude) / 10))
            let request = try! GetAltitudeRequest(host: env.host, locationBody: GetAltitudeByLocationBody(latitude: latitudeAdjusted,
                                                                                                          longitude: longitudeAdjusted)).asURLRequest()
            client.perform(from: request) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(APIError(description: error.localizedDescription)))
                case .success(let result):
                    if result.1.statusCode == 200, let response = try? JSONDecoder().decode(GetAlitutdeByLocationResponse.self,
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
    
    private class GetAltitudeRequest: APIRequest {
        
        var method: HTTPMethod = .post
        
        var host: String
        
        var path: String = APIConstants.getAltitudePath
        
        var queryParameters: [URLQueryItem]? = nil
        
        var body: Data?
        
        var headers: HTTPHeaders?
        
        init(host: String, locationBody: GetAltitudeByLocationBody) {
            var headers = HTTPHeaders()
            headers.add(name: HTTPHeaderName.contentType, value: APIConstants.applicationJson)
            headers.add(name: HTTPHeaderName.acceept, value: APIConstants.applicationJson)
            self.headers = headers
            self.host = host
            let json = try! JSONEncoder().encode(locationBody)
            body = json
        }
    }
}

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
