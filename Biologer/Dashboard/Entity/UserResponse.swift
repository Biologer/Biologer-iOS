//
//  UserResponse.swift
//  Biologer
//
//  Created by Nikola Popovic on 20.9.21..
//

import Foundation

public struct UserDataResponse: Codable {
    let data: UserResponse
    
    public struct UserResponse: Codable {
        let id: Int
        let first_name: String
        let last_name: String
        let email: String
        let full_name: String
        let settings: Settings
        
        public struct Settings: Codable {
            let data_license: Int
            let image_license: Int
            let language: String
        }
    }
}
