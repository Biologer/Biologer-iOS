//
//  FindingRequestBody.swift
//  Biologer
//
//  Created by Nikola Popovic on 10.9.23..
//

import Foundation

public struct FindingResponse: Codable {
    
}

public struct FindingRequestBody: Codable {
    let atlasCode: Int?
    let accuracy: Int?
    let data_license: String?
    let day: String?
    let elevation: Int?
    let found_dead: Int?
    let found_dead_note: String?
    let found_on: String?
    let habitat: String?
    let latitude: Double?
    let longitude: Double?
    let location: String?
    let month: String?
    let note: String?
    let number: Int?
    let observation_types_ids: [Int]?
    let photos: [FindingPhotoRequestBody]?
    let project: String?
    let sex: String?
    let stage_id: Int?
    let taxon_id: Int?
    let taxon_suggestion: String?
    let time: String?
    let year: String?
}

public struct FindingPhotoRequestBody: Codable {
    let license: String
    let path: String
}
