//
//  SideMenuScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 15.6.21..
//

import Foundation

public final class SideMenuScreenViewModel: SideMenuScreenLoader, ObservableObject {
    @Published var menuOpen: Bool = false
    var sideMenuListLoader: SideMenuListScreenViewModel
    var sideMenuMainLoader: SideMenuMainScreenViewModel
    var onItemTapped: Observer<SideMenuItem>
    var onNewItemTapped: Observer<Void>
    
    init(sideMenuListLoader: SideMenuListScreenViewModel,
         sideMenuMainLoader: SideMenuMainScreenViewModel,
         onItemTapped: @escaping Observer<SideMenuItem>,
         onNewItemTapped: @escaping Observer<Void>) {
        self.sideMenuMainLoader = sideMenuMainLoader
        self.sideMenuListLoader = sideMenuListLoader
        self.onItemTapped = onItemTapped
        self.onNewItemTapped = onNewItemTapped
    }
}
