//
//  EnvironmentViewModelFactory.swift
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
                                        env: AppEnvironment(host: APIConstants.serbiaHost,
                                                         path: APIConstants.serbiaLangPath,
                                                         clientSecret: serbiaClientSecret,
                                                         cliendId: cliendIdSer),
                                        isSelected: false)
        case .croatia:
            return EnvironmentViewModel(id: 2,
                                        title: "Env.lb.croatia".localized,
                                        image: "croatia_flag",
                                        env: AppEnvironment(host: APIConstants.croatiaHost,
                                                         path: APIConstants.croatiaLangPath,
                                                         clientSecret: croatiaClientSecret,
                                                         cliendId: cliendIdCro),
                                        isSelected: false)
        case .bosniaAndHerzegovina:
            return EnvironmentViewModel(id: 3, title: "Env.lb.bosniaAndHerzegovina".localized,
                                        image: "bosnia_flag_icon",
                                        env: AppEnvironment(host: APIConstants.bosnianAndHerzegovinHost,
                                                         path: APIConstants.bosnianAndHerzegovinaLangPath,
                                                         clientSecret: bosnianAndHercegovinaClientSecret,
                                                         cliendId: cliendIdBih),
                                        isSelected: false)
        case .montenegro:
            return EnvironmentViewModel(id: 4,
                                        title: "Env.lb.montenegro".localized,
                                        image: "montenegro_flag_icon",
                                        env: AppEnvironment(host: APIConstants.montenegroHost,
                                                         path: APIConstants.montenegroLangPath,
                                                         clientSecret: montenegroClientSecret,
                                                         cliendId: cliendIdMe),
                                        isSelected: false)
        case .develop:
            return EnvironmentViewModel(id: 5,
                                        title: "Env.lb.developer".localized,
                                        image: "hammer_icon",
                                        env: AppEnvironment(host: APIConstants.devHost,
                                                         path: APIConstants.devLangPath,
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
