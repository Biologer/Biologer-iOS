//
//  ListOfFindingsScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.6.21..
//

import Foundation

public enum SideMenuMainScreenPreview {
    case regular([Item])
    case iregular(String)
}

public final class ListOfFindingsScreenViewModel: ListOfFindingsScreenLoader, ObservableObject {
    var onNewItemTapped: Observer<Void>
    var onItemTapped: Observer<Item>
    
    @Published var preview: SideMenuMainScreenPreview = .iregular("No Data")
    
    init(onNewItemTapped: @escaping Observer<Void>,
         onItemTapped: @escaping Observer<Item>) {
        self.onNewItemTapped = onNewItemTapped
        self.onItemTapped = onItemTapped
    }
    
    func getData() {
        // MARK: - Get data from API or DB
        preview = .regular([Item(id: 1, name: "Item 1"),
                            Item(id: 2, name: "Item 2"),
                            Item(id: 3, name: "Item 3"),
                            Item(id: 4, name: "Item 4"),
                            Item(id: 5, name: "Item 5"),
                            Item(id: 6, name: "Item 6")])
    }
}
