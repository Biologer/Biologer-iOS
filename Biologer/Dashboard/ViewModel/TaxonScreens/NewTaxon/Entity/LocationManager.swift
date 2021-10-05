//
//  LocationManager.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.10.21..
//

import Combine
import CoreLocation

public class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    public var onLocationUpdate: Observer<Void>?

     @Published var location: CLLocation? {
       willSet { objectWillChange.send() }
     }
    
    var latitude: CLLocationDegrees {
        return location?.coordinate.latitude ?? 0
    }
    
    var longitude: CLLocationDegrees {
        return location?.coordinate.longitude ?? 0
    }
    
    var altitude: CLLocationDistance {
        return location?.altitude ?? 0
    }
    
    var accuracy: CLLocationAccuracy {
        return location?.horizontalAccuracy ?? 0
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func startUpdateingLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override init() {
      super.init()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        onLocationUpdate?(())
    }
}
