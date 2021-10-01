//
//  TaxonService.swift
//  Biologer
//
//  Created by Nikola Popovic on 1.10.21..
//

import Foundation

public protocol TaxonService {
    func getTaxons(by search: String) -> [TaxonViewModel]
}

public final class DBTaxonService: TaxonService {
    public func getTaxons(by search: String) -> [TaxonViewModel] {
        let taxons = [TaxonViewModel(name: "Mila"),
                      TaxonViewModel(name: "Mika"),
                      TaxonViewModel(name: "Zika"),
                      TaxonViewModel(name: "Mira"),
                      TaxonViewModel(name: "Marko"),
                      TaxonViewModel(name: "Matija"),
                      TaxonViewModel(name: "Milica"),
                      TaxonViewModel(name: "Pedja"),
                      TaxonViewModel(name: "Pera"),
                      TaxonViewModel(name: "Luka123"),
                      TaxonViewModel(name: "Lena"),
                      TaxonViewModel(name: "Luka123"),
                      TaxonViewModel(name: "Luka12234"),
                      TaxonViewModel(name: "Luka123asdfasa"),
                      TaxonViewModel(name: "Luka122543"),
                      TaxonViewModel(name: "Lukaasdfasdfasf"),
        ]
        
        return taxons.filter({ $0.name.contains(search)})
    }
}
