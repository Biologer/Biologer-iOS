//
//  TextUI.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import SwiftUI

struct MenuContent: View {
    var body: some View {
        List {
            Text("My Profile").onTapGesture {
                print("My Profile")
            }
            Text("Posts").onTapGesture {
                print("Posts")
            }
            Text("Logout").onTapGesture {
                print("Logout")
            }
        }
    }
}

struct SideMenu<ScreenLoader>: View where ScreenLoader: SideMenuListScreenLoader {
    let width: CGFloat
    let isOpen: Bool
    let menuClose: () -> Void
    
    @ObservedObject public var loader: ScreenLoader
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .background(Color.gray.opacity(0.3))
            .opacity(self.isOpen ? 1.0 : 0.0)
            .animation(Animation.easeIn.delay(0.25))
            .onTapGesture {
                self.menuClose()
            }
            
            HStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        SideMenuListHeaderView(image: loader.image,
                                               email: loader.email,
                                               username: loader.username)
                        genereateItems(items: loader.items[0])
                        Divider()
                        Text("About us")
                            .padding(.leading, 10)
                        genereateItems(items: loader.items[1])
                    }
                }
                    .frame(width: self.width)
                    .background(Color.white)
                    .offset(x: self.isOpen ? 0 : -self.width)
                    .animation(.default)
                
                Spacer()
            }
        }
    }
    
    private func genereateItems(items: [SideMenuItem]) -> AnyView {
        return AnyView(ForEach(items, id: \.id) { item in
            HStack {
                MenuItemView(title: item.title, image: item.image)
                    .padding(.leading, 20)
            }
            .onTapGesture {
                loader.onItemTapped(item)
            }
        })
    }
}

struct TestSideMenu<ScreenLoader>: View where ScreenLoader: SideMenuScreenLoader {
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
            
            SideMenu(width: 270,
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
