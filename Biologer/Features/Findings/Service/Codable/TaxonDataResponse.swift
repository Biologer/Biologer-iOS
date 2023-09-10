//
//  TaxonDataResponse.swift
//  Biologer
//
//  Created by Nikola Popovic on 10.9.23..
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
