//
//  DBFindingTaxon.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.10.21..
//

import Foundation
import RealmSwift

public final class DBFindingTaxon: Object {
    @Persisted(primaryKey: true) var id: UUID = UUID()
    @Persisted var apiId: Int?
    @Persisted var name: String
    @Persisted var isAtlasCode: Bool = false
    @Persisted var translation: List<DBTaxonTranslations>
    @Persisted var devStage: List<DBTaxonDevStage>
    
    convenience init(apiId: Int?,
                     name: String,
                     isAtlasCode: Bool,
                     translation: List<DBTaxonTranslations>,
                     devStage: List<DBTaxonDevStage>) {
        self.init()
        self.apiId = apiId
        self.name = name
        self.isAtlasCode = isAtlasCode
        self.devStage = devStage
        self.translation = translation
    }
}

public final class DBTaxonTranslations: Object {
    @Persisted var id: Int
    @Persisted var taxonId: Int
    @Persisted var locale: String
    @Persisted var nativeName: String
    @Persisted var descriptionName: String
    
    convenience init(id: Int,
                     taxonId: Int,
                     locale: String,
                     nativeName: String,
                     descriptionName: String) {
        self.init()
        self.id = id
        self.taxonId = taxonId
        self.locale = locale
        self.nativeName = nativeName
        self.descriptionName = descriptionName
    }
}

public final class DBTaxonDevStage: Object {
    @Persisted var id: Int
    @Persisted var name: String
    @Persisted var taxonId: Int

    convenience init(id: Int,
                     name: String,
                     taxonId: Int) {
        self.init()
        self.id = id
        self.name = name
        self.taxonId = taxonId
    }
}
