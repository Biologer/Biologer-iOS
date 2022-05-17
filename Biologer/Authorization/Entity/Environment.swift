//
//  Environment.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.7.21..
//

import Foundation

public final class Environment: Codable {
    public var clientId: String
    public let clientSecret: String
    public let host: String
    public let path: String
    
    init(host: String,
         path: String,
         clientSecret: String,
         cliendId: String) {
        self.host = host
        self.path = path
        self.clientSecret = clientSecret
        self.clientId = cliendId
    }
}
