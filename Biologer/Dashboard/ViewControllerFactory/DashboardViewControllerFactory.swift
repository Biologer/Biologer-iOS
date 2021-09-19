//
//  DashboardViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 26.6.21..
//

import SwiftUI

protocol DashboardViewControllerFactory {
    func makeSideMenuListScreen(onItemTapped: @escaping Observer<SideMenuItem>) -> UIViewController
    func makeListOfFindingsScreen(onNewItemTapped: @escaping Observer<Void>,
                                       onItemTapped: @escaping Observer<Item>) -> UIViewController
    func makeSetupScreen(onItemTapped: @escaping Observer<SetupItemViewModel>) -> UIViewController
    func makeLogoutScreen(onLogoutTapped: @escaping Observer<Void>) -> UIViewController
    func makeAboutScreen(currentEnv: String,
                         version: String,
                         onEnvTapped: @escaping Observer<String>) -> UIViewController
    func makeHelpScreen(onDone: @escaping Observer<Void>) -> UIViewController
}

public final class SwiftUIDashboardViewControllerFactory: DashboardViewControllerFactory {
    
    func makeSideMenuListScreen(onItemTapped: @escaping Observer<SideMenuItem>) -> UIViewController {
        
        let sideMenuListViewModel = SideMenuListScreenViewModel(items: SideMenuMapper.items,
                                                                email: "test@test.com",
                                                                username: "Nikola",
                                                                image: "biloger_background",
                                                                onItemTapped: onItemTapped)
        
        let screen = SideMenuListScreen(loader: sideMenuListViewModel)
        let viewController = UIHostingController(rootView: screen)
        return viewController
    }
    
    func makeListOfFindingsScreen(onNewItemTapped: @escaping Observer<Void>,
                                       onItemTapped: @escaping Observer<Item>) -> UIViewController {
        let sideMenuMainViewModel = ListOfFindingsScreenViewModel(onNewItemTapped: onNewItemTapped,
                                                                onItemTapped: onItemTapped)
        
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
    
    func makeLogoutScreen(onLogoutTapped: @escaping Observer<Void>) -> UIViewController {
        let viewModel = LogoutScreenViewModel(onLogoutTapped: onLogoutTapped)
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
        
    func makeHelpScreen(onDone: @escaping Observer<Void>) -> UIViewController {
        let viewModel = HelpScreenViewModel(onDone: onDone)
        let screen = HelpScreen(loader: viewModel)
        let vc = UIHostingController(rootView: screen)
        return vc
    }
}
