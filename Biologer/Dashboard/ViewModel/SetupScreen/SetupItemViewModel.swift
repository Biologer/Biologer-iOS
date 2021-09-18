//
//  SetupItemViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import Foundation

public enum SetupItemType {
    case chooseGropups
    case englishNames
    case adultByDefault
    case observationEntry
    case projectName
    case dataLicense
    case imageLicense
    case downloadUpload
    case downloadAllTaxa
}

public final class SetupItemViewModel: ObservableObject, Identifiable {
    
    public let id = UUID()
    public let title: String
    public let description: String
    @Published public var isSelected: Bool?
    private let type: SetupItemType
    
    init(title: String,
         description: String,
         isSelected: Bool?,
         type: SetupItemType) {
        self.title = title
        self.description = description
        self.isSelected = isSelected
        self.type = type
    }
}
