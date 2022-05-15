//
//  SetupDownloadAndUploadScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import Foundation

public enum SetupRadioAndTitleModelType: String, Codable {
    case onlyWiFi
    case onAnyNetwork
    case alwaysAskUser
}

public final class SetupRadioAndTitleModel: Identifiable, ObservableObject {
    public let id = UUID()
    @Published public var isSelected: Bool
    public let title: String
    public let type: SetupRadioAndTitleModelType
    
    init(isSelected: Bool,
         title: String,
         type: SetupRadioAndTitleModelType) {
        self.isSelected = isSelected
        self.title = title
        self.type = type
    }
}

public final class SetupDownloadAndUploadScreenViewModel: ObservableObject {
    @Published var items: [SetupRadioAndTitleModel]
    public let cancelButtonTitle = "Common.btn.cancel".localized
    public let title = "DownloadAndUpload.nav.title".localized
    
    private let settingsStorage: SettingsStorage
    private let onCancelTapped: Observer<Void>
    private let onItemTapped: Observer<SetupRadioAndTitleModel>
    
    init(settingsStorage: SettingsStorage,
         onCancelTapped: @escaping Observer<Void>,
         onItemTapped: @escaping Observer<SetupRadioAndTitleModel>) {
        self.settingsStorage = settingsStorage
        self.onCancelTapped = onCancelTapped
        self.onItemTapped = onItemTapped
        self.items = SetupDownloadAndUploadMapper.getItems(settingsStorage: settingsStorage)
    }
    
    public func itemTapped(selectedIndex: Int) {
        items.forEach { $0.isSelected = false }
        let item = items[selectedIndex]
        item.isSelected = true
        
        if let settings = settingsStorage.getSettings() {
            settings.setAutoDownloadTaxonBy(type: item.type)
            settingsStorage.saveSettings(settings: settings)
        }
        
        onItemTapped((item))
    }
    
    public func cancelTapped() {
        onCancelTapped(())
    }
}
