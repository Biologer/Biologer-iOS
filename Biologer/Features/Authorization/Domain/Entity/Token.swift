//
//  Token.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.7.21..
//

import Foundation

public final class Token: Codable {
    public let accessToken: String
    public let refreshToken: String
    
    init(accessToken: String,
         refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    private enum CodingKeys: String, CodingKey {
      case accessToken = "access_token"
      case refreshToken = "refresh_token"
    }
}
