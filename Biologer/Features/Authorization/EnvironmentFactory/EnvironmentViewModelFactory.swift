//
//  EnvironmentViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import Foundation

public final class EnvironmentViewModelFactory {
    public static func createEnvironment(type: EnvironmentType) -> EnvironmentViewModel {
        switch type {
        case .serbia:
            return EnvironmentViewModel(id: 1,
                                        title: "Env.lb.seribia".localized,
                                        image: "serbia_flag",
                                        env: Environment(host: serbiaHost,
                                                         path: serbiaPath,
                                                         clientSecret: serbiaClientSecret,
                                                         cliendId: cliendIdSer),
                                        isSelected: false)
        case .croatia:
            return EnvironmentViewModel(id: 2,
                                        title: "Env.lb.croatia".localized,
                                        image: "croatia_flag",
                                        env: Environment(host: croatiaHost,
                                                         path: croatiaPath,
                                                         clientSecret: croatiaClientSecret,
                                                         cliendId: cliendIdCro),
                                        isSelected: false)
        case .bosniaAndHerzegovina:
            return EnvironmentViewModel(id: 3, title: "Env.lb.bosniaAndHerzegovina".localized,
                                        image: "bosnia_flag_icon",
                                        env: Environment(host: bosnianAndHerzegovinHost,
                                                         path: bosnianAndHerzegovinaPath,
                                                         clientSecret: bosnianAndHercegovinaClientSecret,
                                                         cliendId: cliendIdBih),
                                        isSelected: false)
        case .montenegro:
            return EnvironmentViewModel(id: 4,
                                        title: "Env.lb.montenegro".localized,
                                        image: "montenegro_flag_icon",
                                        env: Environment(host: montenegroHost,
                                                         path: montenegroPath,
                                                         clientSecret: montenegroClientSecret,
                                                         cliendId: cliendIdMe),
                                        isSelected: false)
        case .develop:
            return EnvironmentViewModel(id: 5,
                                        title: "Env.lb.developer".localized,
                                        image: "hammer_icon",
                                        env: Environment(host: devHost,
                                                         path: devPath,
                                                         clientSecret: devClientSecret,
                                                         cliendId: cliendIdDev),
                                        isSelected: false)
        }
    }
    
    public static func createAllEnvironments() -> [EnvironmentViewModel] {
        return [
            createEnvironment(type: .serbia),
            createEnvironment(type: .croatia),
            createEnvironment(type: .bosniaAndHerzegovina),
            createEnvironment(type: .montenegro),
            createEnvironment(type: .develop)
        ]
    }
}