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
                                        title: "Env.lb.seribia".localized,
                                        image: "serbia_flag",
                                        env: Environment(host: serbiaHost, path: serbiaPath, clientSecret: serbiaClientSecret),
                                        isSelected: false)
        case .croatia:
            return EnvironmentViewModel(id: 2,
                                        title: "Env.lb.croatia".localized,
                                        image: "croatia_flag",
                                        env: Environment(host: croatiaHost, path: croatiaPath, clientSecret: croatiaClientSecret),
                                        isSelected: false)
        case .bosniaAndHerzegovina:
            return EnvironmentViewModel(id: 3, title: "Env.lb.bosniaAndHerzegovina".localized,
                                        image: "bosnia_flag_icon",
                                        env: Environment(host: bosnianAndHerzegovinHost, path: bosnianAndHerzegovinaPath, clientSecret: bosnianAndHercegovinaClientSecret),
                                        isSelected: false)
        case .develop:
            return EnvironmentViewModel(id: 4, title: "Env.lb.developer".localized,
                                        image: "hammer_icon",
                                        env: Environment(host: devHost, path: devPath, clientSecret: devClientSecret),
                                        isSelected: false)
        }
    }
}

public struct EnvironmentViewModel: Identifiable, Codable {
     public let id: Int
     public let title: String
     public let image: String
     public let env: Environment
     public var isSelected: Bool
    
    init(id: Int,
         title: String,
         image: String,
         env: Environment,
         isSelected: Bool) {
        self.id = id
        self.title = title
        self.env = env
        self.image = image
        self.isSelected = isSelected
    }
    
    public mutating func changeIsSelected(value: Bool ) {
        isSelected = value
    }
}
