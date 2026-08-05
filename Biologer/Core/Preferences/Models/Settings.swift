//
//  Settings.swift
//  Biologer
//
//  Created by Nikola Popovic on 21.11.21..
//

import Foundation

public enum AutomaticTaxonDownloadPreference: String, Codable {
    case onlyWiFi
    case onAnyNetwork
    case alwaysAskUser
}

public final class Settings: Codable {
    public private(set) var alwaysEnglishName: Bool = false
    public private(set) var setAdultByDefault: Bool = false
    public private(set) var projectName: String = ""
    public private(set) var selectedAutoDownloadTaxon = AutoDownloadTaxon(type: .alwaysAskUser)
    
    public func toggleAlwaysEnglishName() {
        alwaysEnglishName.toggle()
    }
    
    public func toggleSetAdultByDefault() {
        setAdultByDefault.toggle()
    }
    
    public func setProjectName(name: String) {
        projectName = name
    }
    
    public func setAutoDownloadTaxonBy(type: AutomaticTaxonDownloadPreference) {
        selectedAutoDownloadTaxon = AutoDownloadTaxon(type: type)
    }
    
    public final class AutoDownloadTaxon: Codable {
        public let type: AutomaticTaxonDownloadPreference
        
        init(type: AutomaticTaxonDownloadPreference) {
            self.type = type
        }
    }
}
