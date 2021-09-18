//
//  CheckMarkItem.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public enum CheckMarkItemType {
    case data
    case image
}

public struct CheckMarkItem {
    var id: Int
    var title: String
    var placeholder: String
    var licenseType: CheckMarkItemType
    var isSelected: Bool
    
    public mutating func changeIsSelected(value: Bool) {
        isSelected = value
    }
}
