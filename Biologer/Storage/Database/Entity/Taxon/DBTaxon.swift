//
//  DBTaxon.swift
//  Biologer
//
//  Created by Nikola Popovic on 2.11.21..
//

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
}

public final class DBTaxonStages: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String?
    @Persisted var createdAt: String?
    @Persisted var updatedAt: String?
}

public final class DBTaxonTranslation: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var taxonId: String
    @Persisted var locale: String?
    @Persisted var nativeName: String?
    @Persisted var trasnlationDescription: String?
}
