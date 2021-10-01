//
//  TaxonViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 1.10.21..
//

import Foundation

public final class TaxonViewModel {
    let id = UUID()
    let name: String
    
    init(name: String) {
        self.name = name
    }
}
