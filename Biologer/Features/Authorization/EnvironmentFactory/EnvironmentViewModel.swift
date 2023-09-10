//
//  EnvironmentViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 9.9.23..
//

import Foundation

public struct EnvironmentViewModel: Identifiable, Codable {
     public let id: Int
     public let title: String
     public let image: String
     public let env: Environment
     public var isSelected: Bool
    
    init(id: Int,
         title: String,
         image: String,
         env: Environment,
         isSelected: Bool) {
        self.id = id
        self.title = title
        self.env = env
        self.image = image
        self.isSelected = isSelected
    }
    
    public mutating func changeIsSelected(value: Bool ) {
        isSelected = value
    }
}
