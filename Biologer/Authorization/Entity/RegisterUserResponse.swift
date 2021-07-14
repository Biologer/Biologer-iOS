//
//  RegisterUserResponse.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public struct RegisterUserResponse: Codable {
    let access_token: String
    let refresh_token: String
}
