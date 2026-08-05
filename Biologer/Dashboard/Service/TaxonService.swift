//
//  TaxonService.swift
//  Biologer
//
//  Created by Nikola Popovic on 1.10.21..
//

import Foundation

public struct TaxonDataResponse: Codable {
    
    let data: [TaxonResponse]
    let meta: TaxonMetaResponse
    
    public struct TaxonResponse: Codable {
        let id: Int
        let name: String?
        let rank: String?
        let rank_level: Int?
        let restricted: Bool?
        let allochthonous: Bool?
        let invasive: Bool?
        let uses_atlas_codes: Bool?
        let ancestors_names: String?
        let can_edit: Bool?
        let can_delete: Bool?
        let rank_translation: String?
        let native_name: String?
        let description: String?
        let translations: [TaxonTranslationsResponse]?
        let stages: [TaxonStagesResponse]?
    }

    public struct TaxonStagesResponse: Codable {
        let id: Int
        let name: String?
        let created_at: String?
        let updated_at: String?
    }
    
    public struct TaxonTranslationsResponse: Codable {
        let id: Int
        //let taxon_id: String?
        let locale: String?
        let native_name: String?
        let description: String?
    }
    
    public struct TaxonMetaResponse: Codable {
        let current_page: Int
        let from: Int?
        let last_page: Int
        let per_page: String?
        let to: Int?
        let total: Int
    }
}

public protocol TaxonService {
    typealias Result = Swift.Result<TaxonDataResponse, APIError>
    func getTaxons(currentPage: Int,
                   perPage: Int,
                   updatedAfter: Int64,
                   completion: @escaping (Result) -> Void)
}

public final class RemoteTaxonService: TaxonService {
    public typealias Result = Swift.Result<TaxonDataResponse, APIError>
    
    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage
    
    public init(client: APIClientProtocol,
                environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }
    
    public func getTaxons(currentPage: Int,
                          perPage: Int,
                          updatedAfter: Int64,
                          completion: @escaping (Result) -> Void) {
        guard let env = environmentStorage.getEnvironment() else {
            completion(.failure(APIError(description: ErrorConstant.environmentNotSelected)))
            return
        }

        Task {
            do {
                let endpoint = TaxonEndpoint(
                    host: env.host,
                    currentPage: currentPage,
                    perPage: perPage,
                    updatedAfter: updatedAfter
                )
                completion(.success(try await client.send(endpoint)))
            } catch let error as APIClientError {
                completion(.failure(error.asAPIError()))
            } catch {
                completion(.failure(APIError(description: error.localizedDescription)))
            }
        }
    }
}
