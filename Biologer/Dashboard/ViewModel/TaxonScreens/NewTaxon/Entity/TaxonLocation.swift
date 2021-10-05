//
//  TaxonLocation.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import Foundation

public final class TaxonLocation {
    let latitude: Double
    let longitute: Double
    let accuracy: Double
    let altitude: Double
    
    init(latitude: Double,
         longitute: Double,
         accuracy: Double = 0.0,
         altitude: Double = 0.0) {
        self.latitude = latitude
        self.longitute = longitute
        self.accuracy = accuracy
        self.altitude = altitude
    }
}
