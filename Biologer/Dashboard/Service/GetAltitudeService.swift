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
    
    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage
    
    public init(client: APIClientProtocol,
                environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }
    
    public func getAltitude(latitude: Double,
                            longitude: Double,
                            completion: @escaping (Result) -> Void) {
        guard let env = environmentStorage.getEnvironment() else {
            completion(.failure(APIError(description: ErrorConstant.environmentNotSelected)))
            return
        }

        let endpoint = GetAltitudeEndpoint(
            host: env.host,
            latitude: latitude,
            longitude: longitude
        )

        Task {
            do {
                let response = try await client.send(endpoint)
                completion(.success(response))
            } catch let error as APIClientError {
                completion(.failure(error.asAPIError()))
            } catch {
                completion(.failure(APIError(description: error.localizedDescription)))
            }
        }
    }
}

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
