//
//  DBObservationMapper.swift
//  Biologer
//
//  Created by Nikola Popovic on 2.11.21..
//

import Foundation
import RealmSwift

public final class DBObservetationMapper {
    public static func mapForDB(observationResponse: ObservationDataResponse.ObservationResponse) -> DBObservation {
        let dbObservationTranslations = List<DBObservationTranslation>()
        observationResponse.translations.forEach({
            dbObservationTranslations.append(DBObservationTranslation(id: $0.id, local: $0.locale, name: $0.name))
        })
        return DBObservation(id: observationResponse.id,
                             translation: dbObservationTranslations)
    }
}
