//
//  DashboardViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 26.6.21..
//

import SwiftUI

protocol DashboardViewControllerFactory {
    func makeSideMenuListScreen(email: String,
                                username: String,
                                onItemTapped: @escaping Observer<SideMenuItem>) -> UIViewController
    func makeListOfFindingsScreen(onNewItemTapped: @escaping Observer<Void>,
                                       onItemTapped: @escaping Observer<Finding>,
                                       onDeleteFindingTapped: @escaping Observer<Finding>) -> UIViewController
    func makeSetupScreen(onItemTapped: @escaping Observer<SetupItemViewModel>) -> UIViewController
    func makeLogoutScreen(userEmail: String,
                          username: String,
                          currentEnv: String,
                          onLogoutTapped: @escaping Observer<Void>) -> UIViewController
    func makeAboutScreen(currentEnv: String,
                         version: String,
                         onEnvTapped: @escaping Observer<String>) -> UIViewController
}

public final class SwiftUIDashboardViewControllerFactory: DashboardViewControllerFactory {
    
    func makeSideMenuListScreen(email: String,
                                username: String,
                                onItemTapped: @escaping Observer<SideMenuItem>) -> UIViewController {
        
        let sideMenuListViewModel = SideMenuListScreenViewModel(items: SideMenuMapper.items,
                                                                email: email,
                                                                username: username,
                                                                image: "biloger_background",
                                                                onItemTapped: onItemTapped)
        
        let screen = SideMenuListScreen(loader: sideMenuListViewModel)
        let viewController = UIHostingController(rootView: screen)
        return viewController
    }
    
    func makeListOfFindingsScreen(onNewItemTapped: @escaping Observer<Void>,
                                       onItemTapped: @escaping Observer<Finding>,
                                       onDeleteFindingTapped: @escaping Observer<Finding>) -> UIViewController {
        let sideMenuMainViewModel = ListOfFindingsScreenViewModel(onNewItemTapped: onNewItemTapped,
                                                                  onItemTapped: onItemTapped, onDeleteFindingTapped: onDeleteFindingTapped)
        
        let screen = ListOfFindingsScreen(loader: sideMenuMainViewModel)
        let viewController = UIHostingController(rootView: screen)
        return viewController
    }
    
    func makeSetupScreen(onItemTapped: @escaping Observer<SetupItemViewModel>) -> UIViewController {
        let viewModel = SetupScreenViewModel(sections: SetupDataMapper.getSetupData(),
                                             onItemTapped: onItemTapped)
        let screen = SetupScreen(viewModel: viewModel)
        let vc = UIHostingController(rootView: screen)
        return vc
    }
    
    func makeLogoutScreen(userEmail: String,
                          username: String,
                          currentEnv: String,
                          onLogoutTapped: @escaping Observer<Void>) -> UIViewController {
        let viewModel = LogoutScreenViewModel(userEmail: userEmail,
                                              username: username,
                                              currentEnv: currentEnv,
                                              onLogoutTapped: onLogoutTapped)
        let screen = LogoutScreen(loader: viewModel)
        let vc = UIHostingController(rootView: screen)
        return vc
    }
    
    func makeAboutScreen(currentEnv: String,
                         version: String,
                         onEnvTapped: @escaping Observer<String>) -> UIViewController {
        let viewModel = AboutBiologerScreenViewModel(currentEnv: currentEnv,
                                                     version: version,
                                                     onEnvTapped: onEnvTapped)
        let screen = AboutBiologerScreen(loader: viewModel)
        let vc = UIHostingController(rootView: screen)
        return vc
    }
}
