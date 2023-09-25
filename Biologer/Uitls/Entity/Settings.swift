//
//  Settings.swift
//  Biologer
//
//  Created by Nikola Popovic on 21.11.21..
//

import Foundation

public class Settings: Codable {
    public private(set) var chooseSpeciesGroup: Bool = false
    public private(set) var alwaysEnglishName: Bool = false
    public private(set) var setAdultByDefault: Bool = false
    public private(set) var advanceObservationEntry: Bool = false
    public private(set) var projectName: String = ""
    public private(set) var lastTimeTaxonUpdate: Int64 = Calendar.getLastTimeTaxonUpdate
    public private(set) var taxonCSVFileEnv: String? = nil
    public private(set) var selectedAutoDownloadTaxon: AutoDownloadTaxon = AutoDownloadTaxon(type: .alwaysAskUser,
                                                                                isSelected: true)
    public var autoDownloadTaxon: [AutoDownloadTaxon] = [AutoDownloadTaxon(type: .onlyWiFi,
                                                                           isSelected: false),
                                                         AutoDownloadTaxon(type: .onAnyNetwork,
                                                                           isSelected: false),
                                                         AutoDownloadTaxon(type: .alwaysAskUser,
                                                                           isSelected: true)
    ]
    
    public func toggleChooseSpecisGroup() {
        chooseSpeciesGroup.toggle()
    }
    
    public func toggleAlwaysEnglishName() {
        alwaysEnglishName.toggle()
    }
    
    public func toggleSetAdultByDefault() {
        setAdultByDefault.toggle()
    }
    
    public func toggleAdvanceObservationEntry() {
        advanceObservationEntry.toggle()
    }
    
    public func setProjectName(name: String) {
        projectName = name
    }
    
    public func setAutoDownloadTaxonBy(type: SetupRadioAndTitleModelType) {
        autoDownloadTaxon.forEach({ $0.isSelected = false })
        if let selectedItem = autoDownloadTaxon.first(where: { $0.type == type}) {
            selectedItem.isSelected = true
            selectedAutoDownloadTaxon = selectedItem
        }
    }
    
    public func setLastTimeTaxonUpdate(with value: Int64) {
        lastTimeTaxonUpdate = value
    }
    
    public func setTaxonCSVFileEnv(with value: String?) {
        taxonCSVFileEnv = value
    }
    
    public class AutoDownloadTaxon: Codable {
        public var type: SetupRadioAndTitleModelType
        public var isSelected: Bool
        
        init(type: SetupRadioAndTitleModelType,
             isSelected: Bool) {
            self.type = type
            self.isSelected = isSelected
        }
    }
}
