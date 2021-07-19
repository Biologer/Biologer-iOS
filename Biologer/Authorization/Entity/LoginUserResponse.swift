//
//  LoginUserResponse.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public struct LoginUserResponse: Codable {
    let access_token: String
    let refresh_token: String
}
