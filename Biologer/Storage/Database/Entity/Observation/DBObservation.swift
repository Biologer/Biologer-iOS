//
//  Observation.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.10.21..
//

import Foundation
import RealmSwift

public final class DBObservation: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var translation: List<DBObservationTranslation>
    
    convenience init(id: Int,
                     translation: List<DBObservationTranslation>) {
        self.init()
        self.id = id
        self.translation = translation
    }
}

public final class DBObservationTranslation: Object {
    @Persisted var id: Int
    @Persisted var local: String
    @Persisted var name: String
    
    convenience init(id: Int,
                     local: String,
                     name: String) {
        self.init()
        self.id = id
        self.local = local
        self.name = name
    }
}
