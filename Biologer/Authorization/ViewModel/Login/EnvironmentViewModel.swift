//
//  EnvironmentViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import Foundation

public struct EnvironmentViewModel: EnvironmentViewModelProtocol, Identifiable {
     public var id: Int
     public var title: String
     public var placeholder: String
     public var image: String
     public var url: String
     public var isSelected: Bool
    
    init(id: Int,
         title: String,
         placeholder: String,
         image: String,
         url: String,
         isSelected: Bool) {
        self.id = id
        self.title = title
        self.placeholder = placeholder
        self.image = image
        self.url = url
        self.isSelected = isSelected
    }
    
    public mutating func changeIsSelected(value: Bool ) {
        isSelected = value
    }
}
