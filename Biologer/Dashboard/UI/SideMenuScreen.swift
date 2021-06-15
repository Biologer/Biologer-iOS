//
//  SideMenuScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.6.21..
//

import SwiftUI

protocol SideMenuScreenLoader: ObservableObject {
    var sideMenuListLoader: SideMenuListScreenViewModel { get }
    var sideMenuMainLoader: SideMenuMainScreenViewModel { get }
    var onItemTapped: Observer<SideMenuItem> { get }
    var onNewItemTapped: Observer<Void> { get }
}

struct SideMenuScreen<ScreenLoader>: View where ScreenLoader: SideMenuScreenLoader {
    
    @State var showMenu = true
    @ObservedObject public var loader: ScreenLoader
    
    var body: some View {
        
        let drag = DragGesture()
            .onEnded {
                if $0.translation.width < -100 {
                    withAnimation {
                        self.showMenu = false
                    }
                }
            }
        
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                SideMenuMainScreen(loader: loader.sideMenuMainLoader)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .offset(x: self.showMenu ? geometry.size.width/2 : 0)
                    .disabled(self.showMenu ? true : false)
                if self.showMenu {
                    SideMenuListScreen(loader: loader.sideMenuListLoader)
                        .frame(width: geometry.size.width/2)
                        .transition(.move(edge: .leading))
                }
            }
            .gesture(drag)
        }
    }
}

struct SideMenuScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        SideMenuScreen(loader: StubSideMenuScreenViewModel(onItemTapped: { item in},
                                                           onNewItemTapped: { _ in}))
    }
    
    private class StubSideMenuScreenViewModel: SideMenuScreenLoader {
        
        private lazy var firstSectionItems = [SideMenuItem(id: 1, image: "env_icon", title: "List of findings"),
                                         SideMenuItem(id: 2, image: "env_icon", title: "Setup"),
                                         SideMenuItem(id: 3, image: "env_icon", title: "Logout")]
        
        private lazy var secondSectionItems = [SideMenuItem(id: 1, image: "env_icon", title: "About biologer"),
                                         SideMenuItem(id: 2, image: "env_icon", title: "Help")]
        
        private lazy var items = [firstSectionItems, secondSectionItems]
        
        lazy var sideMenuListLoader: SideMenuListScreenViewModel = SideMenuListScreenViewModel(items: items,
                                                                                          email: "test@test.com",
                                                                                          username: "Nikola Popovic",
                                                                                          image: "biloger_background", onItemTapped: { _ in })
        
        var sideMenuMainLoader: SideMenuMainScreenViewModel = SideMenuMainScreenViewModel(onNewItemTapped: { _ in },
                                                                                          onItemTapped: { item in })
        
        var onItemTapped: Observer<SideMenuItem>
        
        var onNewItemTapped: Observer<Void>

        
        init(onItemTapped: @escaping Observer<SideMenuItem>,
             onNewItemTapped: @escaping Observer<Void>) {
            self.onNewItemTapped = onNewItemTapped
            self.onItemTapped = onItemTapped
        }
    }
}
