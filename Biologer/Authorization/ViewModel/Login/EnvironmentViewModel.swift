//
//  EnvironmentViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import Foundation

public enum EnvironmentType {
    case serbia
    case croatia
    case bosniaAndHerzegovina
    case develop
}

public final class EnvironmentViewModelFactory {
    public func createEnvironment(type: EnvironmentType) -> EnvironmentViewModel {
        switch type {
        case .serbia:
            return EnvironmentViewModel(id: 1,
                                        title: "Serbia",
                                        placeholder: "Select Environment",
                                        image: "serbia_flag",
                                        url: "biologer.org",
                                        isSelected: false)
        case .croatia:
            return EnvironmentViewModel(id: 2, title: "Croatia", placeholder: "Select Environment", image: "croatia_flag", url: "biologer.hr", isSelected: false)
        case .bosniaAndHerzegovina:
            return EnvironmentViewModel(id: 3, title: "Bosnia and Herzegovina", placeholder: "Select Environment", image: "bosnia_flag_icon", url: "biologer.ba", isSelected: false)
        case .develop:
            return EnvironmentViewModel(id: 4, title: "For Developers", placeholder: "Select Environment", image: "hammer_icon", url: "dev.biologer.org", isSelected: false)
        }
    }
}

public struct EnvironmentViewModel: EnvironmentViewModelProtocol, Identifiable {
     public let id: Int
     public let title: String
     public let placeholder: String
     public let image: String
     public let url: String
     public var isSelected: Bool
    
    init(id: Int,
         title: String,
         placeholder: String,
         image: String,
         url: String,
         isSelected: Bool) {
        self.id = id
        self.title = title
        self.placeholder = placeholder
        self.image = image
        self.url = url
        self.isSelected = isSelected
    }
    
    public mutating func changeIsSelected(value: Bool ) {
        isSelected = value
    }
}
