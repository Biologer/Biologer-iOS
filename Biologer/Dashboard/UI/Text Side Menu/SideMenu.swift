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
    var onItemTapped: Observer<SideMenuItem> { get }
    var onNewItemTapped: Observer<Void> { get }
}

struct SideMenu<ScreenLoader>: View where ScreenLoader: SideMenuScreenLoader {
    @State var menuOpen: Bool = false
    
    @ObservedObject public var loader: ScreenLoader
    
    var body: some View {
        ZStack {
            if !self.menuOpen {
                Button(action: {
                    self.openMenu()
                }, label: {
                    Text("Open")
                })
            }
            
            SideMenuListScreen(width: 270,
                     isOpen: self.menuOpen,
                     menuClose: self.openMenu, loader: loader.sideMenuListLoader)
        }
    }
    
    func openMenu() {
        self.menuOpen.toggle()
    }
}

struct TestSideMenu_Previews: PreviewProvider {
    static var previews: some View {
        //ContentView()
        Text("")
    }
}
