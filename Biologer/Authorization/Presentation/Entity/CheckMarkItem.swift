//
//  CheckMarkItem.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public enum CheckMarkItemType: String, Codable, Equatable {
    case data
    case image
}

public struct CheckMarkItem: Codable, Equatable, Identifiable {
    public var id: Int
    var title: String
    var placeholder: String
    var type: CheckMarkItemType
    var isSelected: Bool

    public mutating func changeIsSelected(value: Bool) {
        isSelected = value
    }

    public init(
        id: Int,
        title: String,
        placeholder: String,
        type: CheckMarkItemType,
        isSelected: Bool
    ) {
        self.id = id
        self.title = title
        self.placeholder = placeholder
        self.type = type
        self.isSelected = isSelected
    }
}
