//
//  CheckMarkItem.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public enum CheckMarkItemType: String, Codable {
    case data
    case image
}

public struct CheckMarkItem: Codable {
    var id: Int
    var title: String
    var placeholder: String
    var type: CheckMarkItemType
    var isSelected: Bool
    
    public mutating func changeIsSelected(value: Bool) {
        isSelected = value
    }
}
