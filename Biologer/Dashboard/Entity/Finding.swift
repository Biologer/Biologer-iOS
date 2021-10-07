//
//  Item.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.6.21..
//

import Foundation

public class Finding {
    let id: Int
    let taxon: String
    let developmentStage: String
    
    init(id: Int, taxon: String, developmentStage: String) {
        self.id = id
        self.taxon = taxon
        self.developmentStage = developmentStage
    }
}
