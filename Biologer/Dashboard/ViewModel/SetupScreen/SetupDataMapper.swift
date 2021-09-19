//
//  SetupDataMapper.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import Foundation

public final class SetupDataMapper {
    public static func getSetupData() -> [SetupSectionViewModel] {
        
        let firstSection = [SetupItemViewModel(title: "Settings.lb.chooseSpecisGroup.title".localized,
                                               description: "Settings.lb.chooseSpecisGroup.desc".localized,
                                               isSelected: nil,
                                               type: .chooseGropups),
                            SetupItemViewModel(title: "Settings.lb.awayListEnglish.title".localized,
                                               description: "Settings.lb.awayListEnglish.desc".localized,
                                               isSelected: false,
                                               type: .englishNames),
                            SetupItemViewModel(title: "Settings.lb.adultDefault.title".localized,
                                               description: "Settings.lb.adultDefault.desc".localized,
                                               isSelected: true,
                                               type: .adultByDefault),
                            SetupItemViewModel(title: "Settings.lb.advanceObservation.title".localized,
                                               description: "Settings.lb.advanceObservation.desc".localized,
                                               isSelected: true,
                                               type: .observationEntry)
        ]
        
        let secondSection = [SetupItemViewModel(title: "Settings.lb.projectName.title".localized,
                                                description: "Settings.lb.projectName.desc".localized,
                                                isSelected: nil,
                                                type: .projectName),
                             SetupItemViewModel(title: "Settings.lb.dataLicense.title".localized,
                                                description: "Settings.lb.dataLicense.desc".localized,
                                                isSelected: nil,
                                                type: .dataLicense),
                             SetupItemViewModel(title: "Settings.lb.imageLicense.title".localized,
                                                description: "Settings.lb.imageLicense.desc".localized,
                                                isSelected: nil,
                                                type: .imageLicense)
        ]
        
        let thirdSection = [SetupItemViewModel(title: "Settings.lb.autoDownloadUpload.title".localized,
                                               description: "Settings.lb.autoDownloadUpload.desc".localized,
                                               isSelected: nil,
                                               type: .downloadUpload),
                            SetupItemViewModel(title: "Settings.lb.downloadTaxa.title".localized,
                                               description: "Settings.lb.downloadTaxa.desc".localized,
                                               isSelected: nil,
                                               type: .downloadAllTaxa)
        ]
        
        let result = [SetupSectionViewModel(title: "Settings.lb.dataEntry".localized, items: firstSection),
                      SetupSectionViewModel(title: "Settings.lb.userAccount".localized, items: secondSection),
                      SetupSectionViewModel(title: "Settings.lb.otherDownloads".localized, items: thirdSection)
        ]
        
        return result
    }
}
