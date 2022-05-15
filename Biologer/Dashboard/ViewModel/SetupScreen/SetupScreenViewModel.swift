//
//  SetupScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import Foundation

public final class SetupScreenViewModel: ObservableObject, Identifiable {
    public var id = UUID()
    @Published var sections: [SetupSectionViewModel]
    private var onItemTapped: Observer<SetupItemViewModel>
    private let settingsStorage: SettingsStorage
    
    init(settingsStorage: SettingsStorage,
         onItemTapped: @escaping Observer<SetupItemViewModel>) {
        self.sections = SetupDataMapper.getSetupData(storage: settingsStorage)
        self.settingsStorage = settingsStorage
        self.onItemTapped = onItemTapped
    }
    
    public func itemTapped(sectionIndex: Int, itemIndex: Int) {
        let item = sections[sectionIndex].items[itemIndex]
        item.isSelected?.toggle()
        
        switch item.type {
        case .chooseGropups:
            if let settings = self.settingsStorage.getSettings() {
                settings.toggleChooseSpecisGroup()
                self.settingsStorage.saveSettings(settings: settings)
            }
        case .englishNames:
            if let settings = self.settingsStorage.getSettings() {
                settings.toggleAlwaysEnglishName()
                self.settingsStorage.saveSettings(settings: settings)
            }
        case .adultByDefault:
            if let settings = self.settingsStorage.getSettings() {
                settings.toggleSetAdultByDefault()
                self.settingsStorage.saveSettings(settings: settings)
            }
        case .observationEntry:
            if let settings = self.settingsStorage.getSettings() {
                settings.toggleAdvanceObservationEntry()
                self.settingsStorage.saveSettings(settings: settings)
            }
        case .projectName, .imageLicense, .dataLicense, .downloadAllTaxa, .downloadUpload, .resetAllTaxa:
            break
        }
        
        onItemTapped((item))
    }
}
