//
//  AtlasCode.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.10.21..
//

import Foundation
import RealmSwift

public final class DBAtlasCode: Object {
    @Persisted var id:Int
    @Persisted var name: String
    
    convenience init(id: Int, name: String) {
        self.init()
        self.id = id
        self.name = name
    }
}

