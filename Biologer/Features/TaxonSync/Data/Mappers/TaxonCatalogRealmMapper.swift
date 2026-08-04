import RealmSwift

enum TaxonCatalogRealmMapper {
    static func makeDatabaseTaxon(
        from entry: TaxonCatalogEntry
    ) -> DBTaxon {
        let taxon = DBTaxon()
        taxon.id = entry.id
        taxon.name = entry.name
        taxon.rank = entry.rank
        taxon.rankLevel = entry.rankLevel
        taxon.restricted = entry.isRestricted
        taxon.allochthonous = entry.isAllochthonous
        taxon.invasive = entry.isInvasive
        taxon.isAtlasCodeExist = entry.usesAtlasCodes
        taxon.ancestorsName = entry.ancestorNames
        taxon.canEdit = entry.canEdit
        taxon.canDelete = entry.canDelete
        taxon.rankTranslation = entry.rankTranslation
        taxon.nativName = entry.nativeName
        taxon.taxonDescription = entry.details
        taxon.translations.append(
            objectsIn: entry.translations.map {
                makeDatabaseTranslation(
                    from: $0,
                    taxonID: entry.id
                )
            }
        )
        taxon.stages.append(
            objectsIn: entry.stages.map(makeDatabaseStage)
        )
        return taxon
    }

    private static func makeDatabaseTranslation(
        from translation: TaxonCatalogTranslation,
        taxonID: Int
    ) -> DBTaxonTranslation {
        let databaseTranslation = DBTaxonTranslation()
        databaseTranslation.id = translation.id
        databaseTranslation.taxonId = String(taxonID)
        databaseTranslation.locale = translation.locale
        databaseTranslation.nativeName = translation.nativeName
        databaseTranslation.trasnlationDescription = translation.details
        return databaseTranslation
    }

    private static func makeDatabaseStage(
        from stage: TaxonCatalogStage
    ) -> DBTaxonStages {
        let databaseStage = DBTaxonStages()
        databaseStage.id = stage.id
        databaseStage.name = stage.name
        databaseStage.createdAt = stage.createdAt
        databaseStage.updatedAt = stage.updatedAt
        return databaseStage
    }
}
