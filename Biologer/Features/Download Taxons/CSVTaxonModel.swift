//
//  CSVTaxonModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 20.9.23..
//

import Foundation

public final class CSVTaxonModel {
    let name: String
    let id: Int
    
    init(name: String) {
        self.name = name
        self.id = Int.random(in: 1...5000000)
    }
}
