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
    case montenegro
    case develop
}

public final class EnvironmentViewModelFactory {
    public func createEnvironment(type: EnvironmentType) -> EnvironmentViewModel {
        switch type {
        case .serbia:
            return EnvironmentViewModel(id: 1,
                                        title: "Env.lb.serbia".localized,
                                        image: "serbia_flag",
                                        env: Environment(host: serbiaHost,
                                                         path: serbiaLangPath,
                                                         clientSecret: serbiaClientSecret,
                                                         cliendId: cliendIdSer),
                                        isSelected: false)
        case .croatia:
            return EnvironmentViewModel(id: 2,
                                        title: "Env.lb.croatia".localized,
                                        image: "croatia_flag",
                                        env: Environment(host: croatiaHost,
                                                         path: croatiaLangPath,
                                                         clientSecret: croatiaClientSecret,
                                                         cliendId: cliendIdCro),
                                        isSelected: false)
        case .bosniaAndHerzegovina:
            return EnvironmentViewModel(id: 3, title: "Env.lb.bosniaAndHerzegovina".localized,
                                        image: "bosnia_flag_icon",
                                        env: Environment(host: bosnianAndHerzegovinHost,
                                                         path: bosnianAndHerzegovinaLangPath,
                                                         clientSecret: bosnianAndHercegovinaClientSecret,
                                                         cliendId: cliendIdBih),
                                        isSelected: false)
        case .montenegro:
            return EnvironmentViewModel(id: 4,
                                        title: "Env.lb.montenegro".localized,
                                        image: "montenegro_flag_icon",
                                        env: Environment(host: montenegroHost,
                                                         path: montenegroLangPath,
                                                         clientSecret: montenegroClientSecret,
                                                         cliendId: cliendIdMe),
                                        isSelected: false)
        case .develop:
            return EnvironmentViewModel(id: 5,
                                        title: "Env.lb.developer".localized,
                                        image: "hammer_icon",
                                        env: Environment(host: devHost,
                                                         path: devLangPath,
                                                         clientSecret: devClientSecret,
                                                         cliendId: cliendIdDev),
                                        isSelected: false)
        }
    }
    
    public func createAllEnvironments() -> [EnvironmentViewModel] {
        return [
            createEnvironment(type: .serbia),
            createEnvironment(type: .croatia),
            createEnvironment(type: .bosniaAndHerzegovina),
            createEnvironment(type: .montenegro),
            createEnvironment(type: .develop)
        ]
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
