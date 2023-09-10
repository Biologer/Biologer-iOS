//
//  TaxonSearchScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 1.10.21..
//

import Foundation

public protocol TaxonSearchScreenViewModelDelegate {
    func updateTaxonName(taxon: TaxonViewModel)
}

public final class TaxonSearchScreenViewModel: ObservableObject {
    @Published var texons: [TaxonViewModel] = [TaxonViewModel]()
    @Published public private(set) var searchText: String = ""
    private let delegate: TaxonSearchScreenViewModelDelegate?
    private let onTaxonTapped: Observer<TaxonViewModel>
    private let onOkTapped: Observer<TaxonViewModel>
    private let settingsStorage: SettingsStorage
    
    init(delegate: TaxonSearchScreenViewModelDelegate?,
         settingsStorage: SettingsStorage,
         onTaxonTapped: @escaping Observer<TaxonViewModel>,
         onOkTapped: @escaping Observer<TaxonViewModel>) {
        self.delegate = delegate
        self.settingsStorage = settingsStorage
        self.onTaxonTapped = onTaxonTapped
        self.onOkTapped = onOkTapped
    }
    
    public func taxonTapped(taxon: TaxonViewModel) {
        delegate?.updateTaxonName(taxon: taxon)
        onTaxonTapped((taxon))
    }
    
    public func search(search: String, keyboardLanguage: String?) {
        searchText = search
        let predictByName = NSPredicate.init(format: "name beginswith[cd] %@", searchText)
        let predictByNativeName = NSPredicate.init(format: "nativName beginswith[cd] %@", searchText)
        let predictByTranslations = NSPredicate.init(format: "ANY translations.nativeName beginswith[cd] %@", searchText)
        let query = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or,
                                        subpredicates: [predictByName, predictByNativeName, predictByTranslations])
        let dbTaxons = RealmManager.get(fromEntity: DBTaxon.self).filter(query)
        texons.removeAll()
        dbTaxons.forEach({
            texons.append(Mapper.mapFormDBToTaxonViewModel(dbTaxon: $0,
                                                           keyboardLanguage: keyboardLanguage,
                                                           onlyEnglishName: settingsStorage.getSettings()?.alwaysEnglishName ?? false))
        })
    }
    
    public func okTapped() {
        if searchText != "" {
            let taxon = TaxonViewModel(name: searchText)
            delegate?.updateTaxonName(taxon: taxon)
            onOkTapped((taxon))
        }
    }
    
    private class Mapper {
        static func mapFormDBToTaxonViewModel(dbTaxon: DBTaxon,
                                              keyboardLanguage: String?,
                                              onlyEnglishName: Bool) -> TaxonViewModel {
            var devStages: [DevStageViewModel]?
            var translation: [TaxonTranslationViewModel]?
            if dbTaxon.stages.count != 0 {
                devStages = dbTaxon.stages.map({
                    DevStageViewModel(id: $0.id, name: $0.name ?? "")
                })
            }
            
            if dbTaxon.translations.count > 0 {
                translation = dbTaxon.translations.map({
                    TaxonTranslationViewModel(id: $0.id,
                                              taxonId: Int($0.taxonId) ?? 0,
                                              locale: $0.locale ?? "",
                                              nativName: $0.nativeName ?? "",
                                              descriptionName: $0.trasnlationDescription ?? "")
                })
            }
            
            let getTranslationName = getTaxonName(dbTaxon: dbTaxon,
                                                  keyboardLanguage: keyboardLanguage,
                                                  onlyEnglish: onlyEnglishName)
            
            return TaxonViewModel(id: dbTaxon.id,
                                  name: dbTaxon.name + " (\(getTranslationName))",
                                  isAtlasCode: dbTaxon.isAtlasCodeExist ?? false,
                                  devStages: devStages,
                                  selectedDevStage: nil,
                                  selectedAltasCode: nil,
                                  translations: translation)
        }
        
        private static func getTaxonName(dbTaxon: DBTaxon,
                                         keyboardLanguage: String?,
                                         onlyEnglish: Bool) -> String {
            if onlyEnglish {
                return getTaxonName(by: "en", dbTaxon: dbTaxon)
            } else {
                if let keyboardLanguage = keyboardLanguage {
                    return getTaxonName(by: keyboardLanguage, dbTaxon: dbTaxon)
                } else {
                    return getTaxonName(by: "en", dbTaxon: dbTaxon)
                }
            }
        }
        
        private static func getTaxonName(by language: String, dbTaxon: DBTaxon) -> String {
            if let translation = dbTaxon.translations.first(where: { $0.locale == language}) {
                return translation.nativeName ?? dbTaxon.nativName ?? ""
            } else {
                return ""
            }
        }
    }
}

