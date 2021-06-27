//
//  SideMenuListScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.6.21..
//

import SwiftUI

protocol SideMenuListScreenLoader: ObservableObject {
    var items: [[SideMenuItem]] { get }
    var email: String { get }
    var username: String { get }
    var image: String { get }
    var onItemTapped: Observer<SideMenuItem> { get }
}

struct SideMenuListScreen<ScreenLoader>: View where ScreenLoader: SideMenuListScreenLoader {
    
    let width: CGFloat
    let isOpen: Bool
    let menuClose: Observer<Bool>

    @ObservedObject public var loader: ScreenLoader
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .background(Color.gray.opacity(0.3))
            .opacity(isOpen ? 1.0 : 0.0)
            .animation(Animation.easeIn.delay(0.25))
            .onTapGesture {
                menuClose(isOpen)
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
                    .frame(width: width)
                    .background(Color.white)
                    .offset(x: isOpen ? 0 : -width)
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
    }}

struct SideMenuListScreen_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuListScreen(width: 270,
                           isOpen: true,
                           menuClose: { isOpen in },
                           loader: StubSideMenuListScreenLoader(onItemTapped: { _ in }))
    }
    
    private class StubSideMenuListScreenLoader: SideMenuListScreenLoader {
        var items: [[SideMenuItem]] = [[SideMenuItem(id: 1, image: "env_icon", title: "List of findings"),
                                        SideMenuItem(id: 2, image: "env_icon", title: "Setup"),
                                        SideMenuItem(id: 3, image: "env_icon", title: "Logout")],
        [SideMenuItem(id: 1, image: "env_icon", title: "About Biologer"),
         SideMenuItem(id: 2, image: "env_icon", title: "Help")]]
        var email: String = "test@test.com"
        var username: String = "Nikola"
        var image: String = "biloger_background"
        var onItemTapped: Observer<SideMenuItem>
        
        init(onItemTapped: @escaping Observer<SideMenuItem>) {
            self.onItemTapped = onItemTapped
        }
        
    }
}
