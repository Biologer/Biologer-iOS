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
    
    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage
    
    public init(client: APIClientProtocol,
                environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }
    
    public func getObservationTypes(completion: @escaping (Result) -> Void) {
        guard let env = environmentStorage.getEnvironment() else {
            completion(.failure(APIError(description: ErrorConstant.environmentNotSelected)))
            return
        }

        let updatedAfter = UserDefaults.standard.integer(forKey: APIConstants.updatedAfter)
        UserDefaults.standard.set(Int(Date().timeIntervalSince1970), forKey: APIConstants.updatedAfter)

        Task {
            do {
                let endpoint = ObservationTypesEndpoint(host: env.host, updatedAfter: updatedAfter)
                completion(.success(try await client.send(endpoint)))
            } catch let error as APIClientError {
                completion(.failure(error.asAPIError()))
            } catch {
                completion(.failure(APIError(description: error.localizedDescription)))
            }
        }
    }
}
