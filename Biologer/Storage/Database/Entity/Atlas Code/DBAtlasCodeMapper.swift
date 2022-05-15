//
//  DBAtlasCodeMapper.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.10.21..
//

import Foundation
import RealmSwift

public final class DBAtlasCodeMapper {
    
    public static func map() -> List<DBAtlasCode> {
        
        if Locale.current.languageCode == "en" {
            return mapEnglish()
        } else {
            return mapEnglish()
        }
    }
    
    private static func mapEnglish() -> List<DBAtlasCode> {
        return List<DBAtlasCode>()
    }
    
    private static func mapSerbian() -> List<DBAtlasCode> {
        return List<DBAtlasCode>()
    }
    
    private static func mapCroatian() -> List<DBAtlasCode> {
        return List<DBAtlasCode>()
    }
    
    private static func mapBosnian() -> List<DBAtlasCode> {
        return List<DBAtlasCode>()
    }
}
