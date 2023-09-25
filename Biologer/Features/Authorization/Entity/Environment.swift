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

extension Environment {
    var getCSVFile: URL? {
        switch self.host {
        case serbiaHost:
            return CSVFileConstants.srbURL
        case croatiaHost:
            return CSVFileConstants.croURL
        case bosnianAndHerzegovinHost:
            return CSVFileConstants.bihURL
        case montenegroHost:
            return CSVFileConstants.mneURL
        case devHost:
            return CSVFileConstants.srbURL
        default:
            return nil
        }
    }
    
    var getEnvForTaxons: String {
        switch self.host {
        case serbiaHost:
            return CSVFileSettingsEnvironmentConstants.srb
        case croatiaHost:
            return CSVFileSettingsEnvironmentConstants.cro
        case bosnianAndHerzegovinHost:
            return CSVFileSettingsEnvironmentConstants.bih
        case montenegroHost:
            return CSVFileSettingsEnvironmentConstants.mne
        case devHost:
            return CSVFileSettingsEnvironmentConstants.srb
        default:
            return ""
        }
    }
}
