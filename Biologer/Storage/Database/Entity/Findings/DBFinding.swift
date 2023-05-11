//
//  DBFinding.swift
//  Biologer
//
//  Created by Nikola Popovic on 9.10.21..
//

import Foundation
import RealmSwift

public class DBFindingLocation: Object {
    @Persisted(primaryKey: true) var id: UUID = UUID()
    @Persisted var latitude: Double
    @Persisted var longitude: Double
    @Persisted var altitude: Double
    @Persisted var accuracy: Double
    
    convenience init(latitude: Double,
         longitude: Double,
         altitude: Double,
         accuracy: Double) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.accuracy = accuracy
    }
}

public class DBFinding: Object {
    @Persisted(primaryKey: true) var id: UUID = UUID()
    @Persisted var location: DBFindingLocation?
    @Persisted var taxon: DBFindingTaxon?
    @Persisted var images: List<DBFindingImage>
    @Persisted var atlasCode: DBAtlasCode?
    @Persisted var devStage: DBTaxonDevStage?
    @Persisted var individuals: DBFindingIndividuals?
    @Persisted var observations: List<DBFindingObservation>
    @Persisted var comment: String
    @Persisted var habitat: String
    @Persisted var foundOn: String
    @Persisted var foundDead: String
    @Persisted var isUploaded: Bool
    @Persisted var dateOfCreation: Date
    
    convenience init(location: DBFindingLocation,
         images: List<DBFindingImage>,
         taxon: DBFindingTaxon?,
         atlasCode: DBAtlasCode?,
         devStage: DBTaxonDevStage?,
         individuals: DBFindingIndividuals?,
         observations: List<DBFindingObservation>,
         comment: String,
         habitat: String,
         foundOn: String,
         foundDead: String,
         isUploaded: Bool,
         dateOfCreation: Date) {
        self.init()
        self.location = location
        self.images = images
        self.taxon = taxon
        self.atlasCode = atlasCode
        self.devStage = devStage
        self.individuals = individuals
        self.observations = observations
        self.comment = comment
        self.habitat = habitat
        self.foundOn = foundOn
        self.foundDead =  foundDead
        self.isUploaded = isUploaded
        self.dateOfCreation = dateOfCreation
    }
}

public class DBFindingObservation: Object {
    @Persisted var id: Int
    @Persisted var title: String
    @Persisted var isSelected: Bool
    
    convenience init(id: Int,
                     title: String,
                     isSelected: Bool) {
        self.init()
        self.id = id
        self.title = title
        self.isSelected = isSelected
    }
}

public class DBFindingImage: Object {
    @Persisted var name: String
    @Persisted var image: Data
    @Persisted var url: String?
    
    convenience init(name: String,
                     image: Data,
                     url: String?) {
        self.init()
        self.name = name
        self.image = image
        self.url = url
    }
}

public class DBFindingIndividuals: Object {
    @Persisted var male: DBFindingIndividual?
    @Persisted var female: DBFindingIndividual?
    @Persisted var all: DBFindingIndividual?
    
    convenience init(male: DBFindingIndividual?,
                     female: DBFindingIndividual?,
                     all: DBFindingIndividual?) {
        self.init()
        self.male = male
        self.female = female
        self.all = all
    }
}

public class DBFindingIndividual: Object {
    @Persisted var value: Int
    @Persisted var isSelected: Bool

    convenience init(value: Int, isSelected: Bool) {
        self.init()
        self.value = value
        self.isSelected = isSelected
    }
}
