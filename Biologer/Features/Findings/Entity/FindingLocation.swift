//
//  FindingLocation.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import Foundation

public final class FindingLocation {
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
    
    var latitudeString: String {
        let (degrees, minutes, seconds) = latitude.dms
        return String(format: "%d°%d'%d\"%@", abs(degrees), minutes, seconds, degrees >= 0 ? "N" : "S")
    }
    var longitudeString: String {
        let (degrees, minutes, seconds) = longitute.dms
        return String(format: "%d°%d'%d\"%@", abs(degrees), minutes, seconds, degrees >= 0 ? "E" : "W")
    }
}

extension BinaryFloatingPoint {
    var dms: (degrees: Int, minutes: Int, seconds: Int) {
        var seconds = Int(self * 3600)
        let degrees = seconds / 3600
        seconds = abs(seconds % 3600)
        return (degrees, seconds / 60, seconds % 60)
    }
}
