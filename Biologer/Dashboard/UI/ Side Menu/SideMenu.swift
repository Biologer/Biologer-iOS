//
//  TextUI.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import SwiftUI

protocol SideMenuScreenLoader: ObservableObject {
    var sideMenuListLoader: SideMenuListScreenViewModel { get }
    var listOfFindingsLoader: ListOfFindingsScreenViewModel { get }
    var setupScreenLoader: SetupScreenViewModel { get }
    var aboutScreenLoader: AboutBiologerScreenViewModel { get }
    var helpScreenLoader: HelpScreenViewModel { get }
    var menuOpen: Bool { get set }
    var selectedItemType: SideMenuItemType { get set }
    var onItemTapped: Observer<SideMenuItem> { get }
    var onNewItemTapped: Observer<Void> { get }
}

struct SideMenu<ScreenLoader>: View where ScreenLoader: SideMenuScreenLoader {
    
    @ObservedObject public var loader: ScreenLoader
    
    var body: some View {
        ZStack {
            if !loader.menuOpen {
                switch loader.selectedItemType {
                case .listOfFindings:
                    ListOfFindingsScreen(loader: loader.listOfFindingsLoader)
                case .setup:
                    SetupScreen(loader: loader.setupScreenLoader)
                case .logout:
                    Text("Logout")
                case .about:
                    AboutBiologerScreen(loader: loader.aboutScreenLoader)
                case .help:
                    HelpScreen(loader: loader.helpScreenLoader)
                }
            }
            
            SideMenuListScreen(width: 270,
                     isOpen: loader.menuOpen,
                     menuClose: { isOpen in
                        openMenu()
                     },
                     loader: loader.sideMenuListLoader)
        }
    }
    
    func openMenu() {
        loader.menuOpen.toggle()
    }
}

struct TestSideMenu_Previews: PreviewProvider {
    static var previews: some View {
        //ContentView()
        Text("")
    }
}
