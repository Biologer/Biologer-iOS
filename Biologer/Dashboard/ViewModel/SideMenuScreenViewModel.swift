//
//  SideMenuScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 15.6.21..
//

import Foundation

public final class SideMenuScreenViewModel: SideMenuScreenLoader, ObservableObject {

    
    @Published var selectedItemType: SideMenuItemType
    @Published var menuOpen: Bool = false
    var sideMenuListLoader: SideMenuListScreenViewModel
    var listOfFindingsLoader: ListOfFindingsScreenViewModel
    var setupScreenLoader: SetupScreenViewModel
    var aboutScreenLoader: AboutBiologerScreenViewModel
    var helpScreenLoader: HelpScreenViewModel
    var onItemTapped: Observer<SideMenuItem>
    var onNewItemTapped: Observer<Void>
    
    init(sideMenuListLoader: SideMenuListScreenViewModel,
         listOfFindingsLoader: ListOfFindingsScreenViewModel,
         setupScreenLoader: SetupScreenViewModel,
         aboutScreenLoader: AboutBiologerScreenViewModel,
         helpScreenLoader: HelpScreenViewModel,
         selectedItemType: SideMenuItemType,
         onItemTapped: @escaping Observer<SideMenuItem>,
         onNewItemTapped: @escaping Observer<Void>) {
        self.sideMenuListLoader = sideMenuListLoader
        self.listOfFindingsLoader = listOfFindingsLoader
        self.setupScreenLoader = setupScreenLoader
        self.aboutScreenLoader = aboutScreenLoader
        self.helpScreenLoader = helpScreenLoader
        self.selectedItemType = selectedItemType
        self.onItemTapped = onItemTapped
        self.onNewItemTapped = onNewItemTapped
    }
}
