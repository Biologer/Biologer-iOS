//
//  TextUI.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import SwiftUI

protocol SideMenuScreenLoader: ObservableObject {
    var sideMenuListLoader: SideMenuListScreenViewModel { get }
    var sideMenuMainLoader: SideMenuMainScreenViewModel { get }
    var menuOpen: Bool { get set }
    var onItemTapped: Observer<SideMenuItem> { get }
    var onNewItemTapped: Observer<Void> { get }
}

struct SideMenu<ScreenLoader>: View where ScreenLoader: SideMenuScreenLoader {
    
    @ObservedObject public var loader: ScreenLoader
    
    var body: some View {
        ZStack {
            if !loader.menuOpen {
                SideMenuMainScreen(loader: loader.sideMenuMainLoader)
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
