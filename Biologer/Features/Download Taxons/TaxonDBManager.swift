//
//  TaxonDBManager.swift
//  Biologer
//
//  Created by Nikola Popovic on 25.9.23..
//

import Foundation

protocol TaxonDBManager {
    func save(csvModels: [CSVTaxonModel])
    func deleteAll()
}

public final class TaxonRealmDBManager: TaxonDBManager {
    public func save(csvModels: [CSVTaxonModel]) {
        let dbTaxons = csvModels.map { model in
            return DBTaxon(csvModel: model)
        }
        DispatchQueue.main.async {
            RealmManager.add(dbTaxons)
        }
    }
    
    public func deleteAll() {
        RealmManager.delete(fromEntity: DBTaxon.self)
    }
}
