//
//  TaxonTranslationViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 10.9.23..
//

import Foundation

public final class TaxonTranslationViewModel {
    let id: Int
    let taxonId: Int
    let locale: String
    let nativName: String
    let descriptionName: String
    
    init(id: Int,
         taxonId: Int,
         locale: String,
         nativName: String,
         descriptionName: String) {
        self.id = id
        self.taxonId = taxonId
        self.locale = locale
        self.nativName = nativName
        self.descriptionName = descriptionName
    }
}
