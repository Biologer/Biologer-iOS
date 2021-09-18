//
//  SideMenuListScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 15.6.21..
//

import Foundation

public final class SideMenuListScreenViewModel: SideMenuListScreenLoader, ObservableObject {
    @Published var items: [[SideMenuItem]]
    @Published var email: String
    @Published var username: String
    @Published var image: String
    var onItemTapped: Observer<SideMenuItem>
    
    init(items: [[SideMenuItem]],
         email: String,
         username: String,
         image: String,
         onItemTapped: @escaping Observer<SideMenuItem>) {
        self.items = items
        self.email = email
        self.username = username
        self.image = image
        self.onItemTapped = onItemTapped
    }
}
