//
//  DashboardViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 15.6.21..
//

import SwiftUI

protocol DashboardViewControllerFactory {
    func createDashboardViewController(onNewItemTapped: @escaping Observer<Void>,
                                       onItemTapped: @escaping Observer<Item>,
                                       onSideMenuItemTapped: @escaping Observer<SideMenuItem>) -> UIViewController
}

public final class SwiftUIDashboardViewControllerFactory: DashboardViewControllerFactory {
    func createDashboardViewController(onNewItemTapped: @escaping Observer<Void>, onItemTapped: @escaping Observer<Item>, onSideMenuItemTapped: @escaping Observer<SideMenuItem>) -> UIViewController {
     
        let firstSectionListSideMenu = [SideMenuItem(id: 1, image: "env_icon", title: "List of findings"),
                                    SideMenuItem(id: 2, image: "env_icon", title: "Setup"),
                                    SideMenuItem(id: 3, image: "env_icon", title: "Logout")]
        
        let secondSectionListSideMenu = [SideMenuItem(id: 1, image: "env_icon", title: "About Biologer"),
                                    SideMenuItem(id: 2, image: "env_icon", title: "Help")]
        
        let itemsForSideMenu = [firstSectionListSideMenu, secondSectionListSideMenu]
        
        let sideMenuListViewModel = SideMenuListScreenViewModel(items: itemsForSideMenu,
                                                                email: "test@test.com",
                                                                username: "Nikola",
                                                                image: "",
                                                                onItemTapped: onSideMenuItemTapped)
        
        let sideMenuMainViewModel = SideMenuMainScreenViewModel(onNewItemTapped: onNewItemTapped,
                                                                onItemTapped: onItemTapped)
        
        let sideMenuViewModel = SideMenuScreenViewModel(sideMenuListLoader: sideMenuListViewModel,
                                                        sideMenuMainLoader: sideMenuMainViewModel,
                                                        onItemTapped: { _ in },
                                                        onNewItemTapped: { _ in })
        
        let screen = SideMenuScreen(loader: sideMenuViewModel)
        let viewController = UIHostingController(rootView: screen)
        
        return viewController
    }
}
