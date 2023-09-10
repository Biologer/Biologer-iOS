//
//  TaxonMapScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import Foundation
import CoreLocation

public protocol TaxonMapScreenViewModelDelegate {
    func updateLocation(location: FindingLocation)
}

public final class TaxonMapScreenViewModel: ObservableObject {
    public private(set) var locationManager: LocationManager
    public var delegate: TaxonMapScreenViewModelDelegate?
    public var taxonLocation: FindingLocation?
    public var mapType: MapType = .normal
    private let onMapTypeTapped: Observer<Void>
    public var onMapTypeUpdate: Observer<Void>?
    
    var location: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: taxonLocation?.latitude ?? locationManager.latitude,
                                      longitude: taxonLocation?.longitute ?? locationManager.longitude)
    }
    
    init(locationManager: LocationManager,
         taxonLocation: FindingLocation? = nil,
         onMapTypeTapped: @escaping Observer<Void>) {
        self.locationManager = locationManager
        self.taxonLocation = taxonLocation
        self.onMapTypeTapped = onMapTypeTapped
        locationManager.stopTimer()
    }
    
    public func doneTapped(taxonLocation: FindingLocation) {
        self.taxonLocation = taxonLocation
        delegate?.updateLocation(location: taxonLocation)
    }
    
    public func setMarkerToCurrentLocation() {
        taxonLocation = nil
    }
    
    public func mapTypeTapped() {
        onMapTypeTapped(())
    }
}

extension TaxonMapScreenViewModel: MapTypeScreenViewModelDelegate {
    public func updateMapType(type: MapTypeViewModel) {
        self.mapType = type.type
        onMapTypeUpdate?(())
    }
}
