//
//  DashboardViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 26.6.21..
//

import SwiftUI

protocol DashboardViewControllerFactory {
    func createDashboardViewController(onNewItemTapped: @escaping Observer<Void>,
                                       onItemTapped: @escaping Observer<Item>,
                                       onSideMenuItemTapped: @escaping Observer<SideMenuItem>) -> UIViewController
}

public final class SwiftUIDashboardViewControllerFactory: DashboardViewControllerFactory {
    func createDashboardViewController(onNewItemTapped: @escaping Observer<Void>,
                                       onItemTapped: @escaping Observer<Item>,
                                       onSideMenuItemTapped: @escaping Observer<SideMenuItem>) -> UIViewController {
     
        let firstSectionListSideMenu = [SideMenuItem(id: 1, image: "env_icon",
                                                     title: "List of findings",
                                                     type: .listOfFindings),
                                        SideMenuItem(id: 2, image: "env_icon",
                                                     title: "Setup",
                                                     type: .setup),
                                        SideMenuItem(id: 3,
                                                     image: "env_icon",
                                                     title: "Logout",
                                                     type: .logout)]
        
        let secondSectionListSideMenu = [SideMenuItem(id: 1,
                                                      image: "env_icon",
                                                      title: "About Biologer",
                                                      type: .about),
                                         SideMenuItem(id: 2,
                                                      image: "env_icon",
                                                      title: "Help",
                                                      type: .help)]
        
        let itemsForSideMenu = [firstSectionListSideMenu, secondSectionListSideMenu]
        
        let sideMenuListViewModel = SideMenuListScreenViewModel(items: itemsForSideMenu,
                                                                email: "test@test.com",
                                                                username: "Nikola",
                                                                image: "biloger_background",
                                                                onItemTapped: onSideMenuItemTapped)
        
        let sideMenuMainViewModel = ListOfFindingsScreenViewModel(onNewItemTapped: onNewItemTapped,
                                                                onItemTapped: onItemTapped)
        
        let setupViewModel = SetupScreenViewModel()
        let aboutViewModel = AboutBiologerScreenViewModel()
        let helpViewModel = HelpScreenViewModel()
        
        let sideMenuViewModel = SideMenuScreenViewModel(sideMenuListLoader: sideMenuListViewModel,
                                                        listOfFindingsLoader: sideMenuMainViewModel,
                                                        setupScreenLoader: setupViewModel,
                                                        aboutScreenLoader: aboutViewModel,
                                                        helpScreenLoader: helpViewModel,
                                                        selectedItemType: .listOfFindings,
                                                        onItemTapped: onSideMenuItemTapped,
                                                        onNewItemTapped: onNewItemTapped)
        
        let screen = SideMenu(loader: sideMenuViewModel)
        let viewController = UIHostingController(rootView: screen)
        
        return viewController
    }
}
