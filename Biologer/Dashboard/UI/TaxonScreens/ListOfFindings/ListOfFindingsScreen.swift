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
    var onItemTapped: Observer<Finding> { get }
    var onDeleteFindingTapped: Observer<Finding> { get }
    var preview: SideMenuMainScreenPreview { get }
}

struct ListOfFindingsScreen<ScreenLoader>: View where ScreenLoader: ListOfFindingsScreenLoader {
    
    @ObservedObject public var loader: ScreenLoader
    
    var body: some View {
        generateView(loader)
            .onAppear {
                loader.getData()
            }
            .background(Color.biologerGreenColor.opacity(0.4))
            .ignoresSafeArea(.container, edges: .bottom)
    }
    
    private func generateView(_ screenLoader: ScreenLoader) -> AnyView {
        switch loader.preview {
        case .regular(let items):
            return AnyView(FindingsListView(items: items,
                                            onItemTapped: loader.onItemTapped,
                                            onDeleteFindingTapped: loader.onDeleteFindingTapped,
                                            onNewItemTapped: loader.onNewItemTapped))
        case .iregular(let title):
            return AnyView(NoItemsView(title: title))
        }
    }
}

struct SideMenuMainScreen_Previews: PreviewProvider {
    static var previews: some View {
        ListOfFindingsScreen(loader: StubSideMenuMainScreenViewModel(onNewItemTapped: { _ in },
                                                                     onItemTapped: { _ in}, onDeleteFindingTapped: { _ in }))
    }
    
    private class StubSideMenuMainScreenViewModel: ListOfFindingsScreenLoader {
        var onDeleteFindingTapped: Observer<Finding>
        
        func getData() {}
        
        var onNewItemTapped: Observer<Void>
        
        var onItemTapped: Observer<Finding>
        
        var preview: SideMenuMainScreenPreview = .regular([Finding(id: 1, taxon: "Zerynthia polyxena", developmentStage: "Larva"),
                                                           Finding(id: 2, taxon: "Salamandra salamandra", developmentStage: "Adult"),
                                                           Finding(id: 3, taxon: "Salamandra salamandra", developmentStage: "Adult")])
        init(onNewItemTapped: @escaping Observer<Void>,
             onItemTapped: @escaping Observer<Finding>,
             onDeleteFindingTapped: @escaping Observer<Finding>) {
            self.onItemTapped = onItemTapped
            self.onNewItemTapped = onNewItemTapped
            self.onDeleteFindingTapped = onDeleteFindingTapped
        }
        
    }
}
