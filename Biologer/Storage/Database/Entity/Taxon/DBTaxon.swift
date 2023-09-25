//
//  DBTaxon.swift
//  Biologer
//
//  Created by Nikola Popovic on 2.11.21..
//

import Foundation
import RealmSwift

public final class DBTaxon: Object {

    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var rank: String?
    @Persisted var rankLevel: Int?
    @Persisted var restricted: Bool?
    @Persisted var allochthonous: Bool?
    @Persisted var invasive: Bool?
    @Persisted var ancestorsName: String?
    @Persisted var isAtlasCodeExist: Bool?
    @Persisted var canEdit: Bool?
    @Persisted var canDelete: Bool?
    @Persisted var rankTranslation: String?
    @Persisted var nativName: String?
    @Persisted var taxonDescription: String?
    @Persisted var stages: List<DBTaxonStages>
    @Persisted var translations: List<DBTaxonTranslation>

    convenience init(taxon: TaxonDataResponse.TaxonResponse) {
        self.init()
        self.id = taxon.id
        self.name = taxon.name ?? ""
        self.rank = taxon.rank
        self.rankLevel = taxon.rank_level
        self.restricted = taxon.restricted
        self.allochthonous = taxon.allochthonous
        self.invasive = taxon.invasive
        self.ancestorsName = taxon.ancestors_names
        self.isAtlasCodeExist = taxon.uses_atlas_codes
        self.canEdit = taxon.can_edit
        self.canDelete = taxon.can_delete
        self.rankTranslation = taxon.rank_translation
        self.nativName = taxon.native_name
        self.taxonDescription = taxon.description
        self.stages = List<DBTaxonStages>()
        self.translations = List<DBTaxonTranslation>()
        taxon.translations?.forEach({
            translations.append(DBTaxonTranslation(translation: $0))
        })
        taxon.stages?.forEach({
            stages.append(DBTaxonStages(stage: $0))
        })
    }
    
    convenience init(csvModel: CSVTaxonModel) {
        self.init()
        self.id = csvModel.id
        self.name = csvModel.name
        self.rank = ""
        self.rankLevel = 1
        self.restricted = false
        self.allochthonous = false
        self.invasive = false
        self.ancestorsName = ""
        self.isAtlasCodeExist = false
        self.canEdit = false
        self.canDelete = false
        self.rankTranslation = ""
        self.nativName = ""
        self.taxonDescription = ""
        self.stages = List<DBTaxonStages>()
        self.translations = List<DBTaxonTranslation>()
    }
}

public final class DBTaxonStages: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String?
    @Persisted var createdAt: String?
    @Persisted var updatedAt: String?

    convenience init(stage: TaxonDataResponse.TaxonStagesResponse) {
        self.init()
        self.id = stage.id
        self.name = stage.name
        self.createdAt = stage.created_at
        self.updatedAt = stage.updated_at
    }
}

public final class DBTaxonTranslation: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var taxonId: String
    @Persisted var locale: String?
    @Persisted var nativeName: String?
    @Persisted var trasnlationDescription: String?

    convenience init(translation: TaxonDataResponse.TaxonTranslationsResponse) {
        self.init()
        self.id = translation.id
        self.taxonId = ""
        self.locale = translation.locale
        self.nativeName = translation.native_name
        self.trasnlationDescription = translation.description
    }
}
