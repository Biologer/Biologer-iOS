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
    private let useCase: SetupUseCase
    
    init(useCase: SetupUseCase,
         onItemTapped: @escaping Observer<SetupItemViewModel>) {
        self.sections = SetupDataMapper.getSetupData(settings: useCase.currentSettings())
        self.useCase = useCase
        self.onItemTapped = onItemTapped
    }

    convenience init(
        settingsStorage: SettingsStorage,
        onItemTapped: @escaping Observer<SetupItemViewModel>
    ) {
        self.init(
            useCase: SettingsStorageSetupUseCase(settingsStorage: settingsStorage),
            onItemTapped: onItemTapped
        )
    }
    
    @discardableResult
    public func itemTapped(sectionIndex: Int, itemIndex: Int) -> SetupItemViewModel {
        let item = sections[sectionIndex].items[itemIndex]
        item.isSelected?.toggle()
        
        switch item.type {
        case .chooseGropups, .englishNames, .adultByDefault, .observationEntry:
            useCase.toggleSetting(for: item.type)
        case .projectName, .imageLicense, .dataLicense, .downloadAllTaxa, .downloadUpload, .resetAllTaxa:
            break
        }
        
        onItemTapped((item))
        return item
    }
}
