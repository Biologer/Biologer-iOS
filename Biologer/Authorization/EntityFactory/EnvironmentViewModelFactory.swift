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
                                        host: "biologer.org",
                                        path: "/sr",
                                        isSelected: false)
        case .croatia:
            return EnvironmentViewModel(id: 2, title: "Croatia", placeholder: "Select Environment", image: "croatia_flag", host: "biologer.hr", path: "/hr", isSelected: false)
        case .bosniaAndHerzegovina:
            return EnvironmentViewModel(id: 3, title: "Bosnia and Herzegovina", placeholder: "Select Environment", image: "bosnia_flag_icon", host: "biologer.ba", path: "/ba", isSelected: false)
        case .develop:
            return EnvironmentViewModel(id: 4, title: "For Developers", placeholder: "Select Environment", image: "hammer_icon", host: "dev.biologer.org", path: "/sr", isSelected: false)
        }
    }
}

public struct EnvironmentViewModel: EnvironmentViewModelProtocol, Identifiable, Codable {
     public let id: Int
     public let title: String
     public let placeholder: String
     public let image: String
     public let host: String
    public let path: String
     public var isSelected: Bool
    
    init(id: Int,
         title: String,
         placeholder: String,
         image: String,
         host: String,
         path: String,
         isSelected: Bool) {
        self.id = id
        self.title = title
        self.placeholder = placeholder
        self.image = image
        self.host = host
        self.path = path
        self.isSelected = isSelected
    }
    
    public mutating func changeIsSelected(value: Bool ) {
        isSelected = value
    }
}
