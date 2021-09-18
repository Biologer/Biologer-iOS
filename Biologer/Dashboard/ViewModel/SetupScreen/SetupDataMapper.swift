//
//  SetupDataMapper.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import Foundation

public final class SetupDataMapper {
    public static func getSetupData() -> [SetupSectionViewModel] {
        
        let firstSection = [SetupItemViewModel(title: "Choose Species groups",
                                                description: "By selecting only certain groups (i.e. birds, butterflies or plants) it will be easier to find species for data entry. Other species will not pop up in the drop down menu.",
                                                isSelected: nil,
                                                onItemTapped: { _ in }),
                                SetupItemViewModel(title: "Always list english names",
                                                description: "Allows Biologer list english names for thespecies even if the phone locale is set to other language",
                                                isSelected: false,
                                                onItemTapped: { _ in}),
                                SetupItemViewModel(title: "Set as adult by degault",
                                                   description: "Sets the life stage to adult by default, if adult stage exist for observed taxa.",
                                                   isSelected: true,
                                                   onItemTapped: { _ in}),
                                SetupItemViewModel(title: "Advance observation entry",
                                                   description: "Enables adnvace opstions that could be entered with your occurrence (i.e. number of individuals, stage, sex).",
                                                   isSelected: true,
                                                   onItemTapped: { _ in})
        ]
        
        let secondSection = [SetupItemViewModel(title: "Project Name",
                                               description: "Sets the project title if your data was collected during a project",
                                               isSelected: nil,
                                               onItemTapped: { _ in }),
                            SetupItemViewModel(title: "Data License",
                                                            description: "Choose diffeten license four your data collected through the application",
                                                            isSelected: nil,
                                                            onItemTapped: { _ in }),
                            SetupItemViewModel(title: "Image License",
                                                            description: "Choose diffeten license four your iamge sent through the application",
                                                            isSelected: nil,
                                                            onItemTapped: { _ in })
        ]
        
        let thirdSection = [SetupItemViewModel(title: "Auto download and upload",
                                               description: "Allows data to be automatically downloaded and uploaded without user intervation. By default the data will be transferred only on WiFi.",
                                               isSelected: nil,
                                               onItemTapped: { _ in}),
                            SetupItemViewModel(title: "Download all taxa",
                                               description: "Re-downloads entire taxonomic tree in your application from Biologer server",
                                               isSelected: nil,
                                               onItemTapped: { _ in})
        ]
        
        let result = [SetupSectionViewModel(title: "Data Entry", items: firstSection),
                      SetupSectionViewModel(title: "User Account", items: secondSection),
                      SetupSectionViewModel(title: "Other downloads", items: thirdSection)
        ]
        
        return result
    }
}
