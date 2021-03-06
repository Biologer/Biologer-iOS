//
//  APIConstants.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import Foundation

public final class APIConstants {
    
    // MARK: - Paths
    public static let registerUserPath = "/api/register"
    public static let loginUserPath = "/oauth/token"
    public static let myProfilePath = "/api/my/profile"
    public static let observationsPath = "/api/observation-types"
    
    // MARK: - Common
    public static let applicationJson = "application/json"
    public static let grantTypePassword = "password"
    public static let grantTypeRefreshToken = "refresh_token"
    public static let scope = "*"
}
