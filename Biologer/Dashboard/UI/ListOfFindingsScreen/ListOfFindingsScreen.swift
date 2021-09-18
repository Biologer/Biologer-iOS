//
//  ListOfFindingsScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.6.21..
//

import SwiftUI
 
protocol ListOfFindingsScreenLoader: ObservableObject {
    func getData()
    var onNewItemTapped: Observer<Void> { get }
    var onItemTapped: Observer<Item> { get }
    var preview: SideMenuMainScreenPreview { get }
}

struct ListOfFindingsScreen<ScreenLoader>: View where ScreenLoader: ListOfFindingsScreenLoader {
    
    @ObservedObject public var loader: ScreenLoader
    
    var body: some View {
        return generateView(loader)
            .onAppear {
                loader.getData()
            }
    }
    
    private func generateView(_ screenLoader: ScreenLoader) -> AnyView {
        switch loader.preview {
        case .regular(let items):
            return AnyView(FindingsListView(items: items,
                                         onItemTapped: loader.onItemTapped,
                                         onNewItemTapped: loader.onNewItemTapped))
        case .iregular(let title):
            return AnyView(NoItemsView(title: title))
        }
    }
}

struct SideMenuMainScreen_Previews: PreviewProvider {
    static var previews: some View {
        ListOfFindingsScreen(loader: StubSideMenuMainScreenViewModel(onNewItemTapped: { _ in },
                                                                   onItemTapped: { _ in}))
    }
    
    private class StubSideMenuMainScreenViewModel: ListOfFindingsScreenLoader {
        func getData() {}
        
        var onNewItemTapped: Observer<Void>
        
        var onItemTapped: Observer<Item>
        
        var preview: SideMenuMainScreenPreview = .regular([Item(id: 1, name: "Item 1"),
                                                           Item(id: 2, name: "Item 2"),
                                                           Item(id: 3, name: "Item 3"),
                                                           Item(id: 4, name: "Item 4"),
                                                           Item(id: 5, name: "Item 5")])
        init(onNewItemTapped: @escaping Observer<Void>,
             onItemTapped: @escaping Observer<Item>) {
            self.onItemTapped = onItemTapped
            self.onNewItemTapped = onNewItemTapped
        }
        
    }
}
