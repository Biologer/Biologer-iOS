//
//  TaxonViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 1.10.21..
//

import Foundation

public final class TaxonViewModel {
    let id: Int?
    let name: String
    let isAtlasCode: Bool
    let devStages: [DevStageViewModel]?
    var selectedDevStage: DevStageViewModel?
    var selectedAltasCode: NestingAtlasCodeItem?
    let translations: [TaxonTranslationViewModel]?
    
    init(id: Int? = nil,
         name: String,
         isAtlasCode: Bool = false,
         devStages: [DevStageViewModel]? = nil,
         selectedDevStage: DevStageViewModel? = nil,
         selectedAltasCode: NestingAtlasCodeItem? = nil,
         translations: [TaxonTranslationViewModel]? = nil) {
        self.id = id
        self.name = name
        self.isAtlasCode = isAtlasCode
        self.devStages = devStages
        self.selectedDevStage = selectedDevStage
        self.selectedAltasCode = selectedAltasCode
        self.translations = translations
    }
    
    public func getTranslationName(by language: String) -> String {
        if let translations = translations {
            let translation = translations.first(where: { $0.locale == language})
            return translation?.nativName ?? ""
        } else {
            return name
        }
    }

}
