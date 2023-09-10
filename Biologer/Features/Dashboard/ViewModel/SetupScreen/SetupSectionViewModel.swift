//
//  SetupSectionViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import Foundation

public final class SetupSectionViewModel: ObservableObject {
    public let title: String
    @Published public var items: [SetupItemViewModel]
    public var onItemTapped: Observer<SetupItemViewModel>?
    
    init(title: String, items: [SetupItemViewModel]) {
        self.title = title
        self.items = items
    }
}
