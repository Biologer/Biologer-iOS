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
    func makeSetupScreen() -> UIViewController
    func makeLogoutScreen(onLogoutTapped: @escaping Observer<Void>) -> UIViewController
    func makeAboutScreen() -> UIViewController
    func makeHelpScreen(onDone: @escaping Observer<Void>) -> UIViewController
}

public final class SwiftUIDashboardViewControllerFactory: DashboardViewControllerFactory {
    
    func makeSideMenuListScreen(onItemTapped: @escaping Observer<SideMenuItem>) -> UIViewController {
        
        let firstSectionListSideMenu = [SideMenuItem(id: 1, image: "list_of_findings_icon",
                                                     title: "List of findings",
                                                     type: .listOfFindings),
                                        SideMenuItem(id: 2, image: "setup_icon",
                                                     title: "Setup",
                                                     type: .setup),
                                        SideMenuItem(id: 3,
                                                     image: "logout_icon",
                                                     title: "Logout",
                                                     type: .logout)]
        
        let secondSectionListSideMenu = [SideMenuItem(id: 1,
                                                      image: "about_icon",
                                                      title: "About Biologer",
                                                      type: .about),
                                         SideMenuItem(id: 2,
                                                      image: "help_icon",
                                                      title: "Help",
                                                      type: .help)]
        
        let itemsForSideMenu = [firstSectionListSideMenu, secondSectionListSideMenu]
        
        let sideMenuListViewModel = SideMenuListScreenViewModel(items: itemsForSideMenu,
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
    
    func makeSetupScreen() -> UIViewController {
        let viewModel = SetupScreenViewModel()
        let screen = SetupScreen(loader: viewModel)
        let vc = UIHostingController(rootView: screen)
        return vc
    }
    
    func makeLogoutScreen(onLogoutTapped: @escaping Observer<Void>) -> UIViewController {
        let viewModel = LogoutScreenViewModel(onLogoutTapped: onLogoutTapped)
        let screen = LogoutScreen(loader: viewModel)
        let vc = UIHostingController(rootView: screen)
        return vc
    }
    
    func makeAboutScreen() -> UIViewController {
        let viewModel = AboutBiologerScreenViewModel()
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
