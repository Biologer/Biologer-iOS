extension TaxonUpdatesResponse {
    var asDomain: TaxonSyncPage {
        TaxonSyncPage(
            entries: data.map(\.asDomain),
            currentPage: meta.currentPage,
            lastPage: meta.lastPage,
            totalEntries: meta.total
        )
    }
}

private extension TaxonUpdatesResponse.Taxon {
    var asDomain: TaxonCatalogEntry {
        TaxonCatalogEntry(
            id: id,
            name: name ?? "",
            rank: rank,
            rankLevel: rankLevel,
            isRestricted: isRestricted,
            isAllochthonous: isAllochthonous,
            isInvasive: isInvasive,
            usesAtlasCodes: usesAtlasCodes,
            ancestorNames: ancestorNames,
            canEdit: canEdit,
            canDelete: canDelete,
            rankTranslation: rankTranslation,
            nativeName: nativeName,
            details: details,
            translations: translations?.map(\.asDomain) ?? [],
            stages: stages?.map(\.asDomain) ?? []
        )
    }
}

private extension TaxonUpdatesResponse.Translation {
    var asDomain: TaxonCatalogTranslation {
        TaxonCatalogTranslation(
            id: id,
            locale: locale,
            nativeName: nativeName,
            details: details
        )
    }
}

private extension TaxonUpdatesResponse.Stage {
    var asDomain: TaxonCatalogStage {
        TaxonCatalogStage(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
