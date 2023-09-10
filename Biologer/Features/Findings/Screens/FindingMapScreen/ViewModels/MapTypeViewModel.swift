//
//  MapTypeViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 10.9.23..
//

import Foundation

public final class MapTypeViewModel {
    let id = UUID()
    let name: String
    let type: MapType
    
    init(name: String,
         type: MapType) {
        self.name = name
        self.type = type
    }
}
