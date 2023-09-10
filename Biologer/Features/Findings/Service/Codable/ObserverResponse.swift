//
//  ObserverResponse.swift
//  Biologer
//
//  Created by Nikola Popovic on 21.9.21..
//

import Foundation

public struct ObservationDataResponse: Codable {
    let data: [ObservationResponse]
    
    public struct ObservationResponse: Codable {
        let id: Int
        let slug: String
        let translations: [ObservationTranslationResponse]
    }
    
    public struct ObservationTranslationResponse: Codable {
        let id: Int
        let locale: String
        let name: String
    }
}
