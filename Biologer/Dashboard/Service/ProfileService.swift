//
//  ProfileService.swift
//  Biologer
//
//  Created by Nikola Popovic on 20.9.21..
//

import Foundation

public protocol ProfileService {
    typealias ProfileResult = Swift.Result<UserDataResponse, APIError>
    typealias DeletionResult = Swift.Result<Void, APIError>
    
    func getMyProfile(completion: @escaping (ProfileResult) -> Void)
    func deleteUser(userID: Int, deleteObservations: Bool, completion: @escaping (DeletionResult) -> Void)
}

public class RemoteProfileService: ProfileService {
    
    public typealias ProfileResult = Swift.Result<UserDataResponse, APIError>
    public typealias DeletionResult = Swift.Result<Void, APIError>
    
    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage
    
    public init(client: APIClientProtocol,
                environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }
    
    public func getMyProfile(completion: @escaping (ProfileResult) -> Void) {
        guard let env = environmentStorage.getEnvironment() else {
            completion(.failure(APIError(description: ErrorConstant.environmentNotSelected)))
            return
        }

        Task {
            do {
                completion(.success(try await client.send(GetProfileEndpoint(host: env.host))))
            } catch let error as APIClientError {
                completion(.failure(error.asAPIError()))
            } catch {
                completion(.failure(APIError(description: error.localizedDescription)))
            }
        }
    }
    
    public func deleteUser(userID: Int, deleteObservations: Bool, completion: @escaping (DeletionResult) -> Void) {
        guard let env = environmentStorage.getEnvironment() else {
            completion(.failure(APIError(description: ErrorConstant.environmentNotSelected)))
            return
        }

        Task {
            do {
                _ = try await client.send(
                    DeleteAccountEndpoint(
                        host: env.host,
                        userID: userID,
                        deleteObservations: deleteObservations
                    )
                )
                completion(.success(()))
            } catch let error as APIClientError {
                completion(.failure(error.asAPIError()))
            } catch {
                completion(.failure(APIError(description: error.localizedDescription)))
            }
        }
    }
}
