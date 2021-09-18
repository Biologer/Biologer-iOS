//
//  SetupItemViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import Foundation

public final class SetupItemViewModel: ObservableObject, Identifiable {
    
    public let id = UUID()
    public let title: String
    public let description: String
    @Published public var isSelected: Bool?
    
    private let onItemTapped: Observer<Void>
    
    init(title: String,
         description: String,
         isSelected: Bool?,
         onItemTapped: @escaping Observer<Void>) {
        self.title = title
        self.description = description
        self.isSelected = isSelected
        self.onItemTapped = onItemTapped
    }
    
    public func itemTapped() {
        isSelected?.toggle()
        onItemTapped(())
    }
}
