//
//  DataLicenseScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 8.7.21..
//

import Foundation

public protocol CheckMarkScreenDelegate {
    func get(item: CheckMarkItem)
}

public final class CheckMarkScreenViewModel: CheckMarkScreenLoader {
    var items: [CheckMarkItem]
    
    private let onItemTapped: Observer<CheckMarkItem>
    private let delegate: CheckMarkScreenDelegate?
    
    init(items: [CheckMarkItem],
         selectedItem: CheckMarkItem,
         delegate: CheckMarkScreenDelegate? = nil,
         onItemTapped: @escaping Observer<CheckMarkItem>) {
        self.items = items
        self.delegate = delegate
        self.onItemTapped = onItemTapped
        updateSelectedViewModel(with: selectedItem)
    }
    
    func itemTapped(item: CheckMarkItem) {
        delegate?.get(item: item)
        onItemTapped((item))
    }
    
    public func updateSelectedViewModel(with item: CheckMarkItem) {

        for (index, lic) in items.enumerated() {
            if lic.id == item.id {
                items[index].changeIsSelected(value: true)
            } else {
                items[index].changeIsSelected(value: false)
            }
        }
    }
}
