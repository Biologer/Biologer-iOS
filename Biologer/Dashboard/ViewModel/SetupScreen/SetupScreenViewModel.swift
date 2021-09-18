//
//  SetupScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import Foundation

public final class SetupScreenViewModel: ObservableObject, Identifiable {
    public var id = UUID()
    @Published var sections: [SetupSectionViewModel]
    private var onItemTapped: Observer<SetupItemViewModel>
    
    init(sections: [SetupSectionViewModel],
         onItemTapped: @escaping Observer<SetupItemViewModel>) {
        self.sections = sections
        self.onItemTapped = onItemTapped
    }
    
    public func itemTapped(sectionIndex: Int, itemIndex: Int) {
        let item = sections[sectionIndex].items[itemIndex]
        item.isSelected?.toggle()
        onItemTapped((item))
    }
}
