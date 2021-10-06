//
//  TaxonMapScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import Foundation

public protocol TaxonMapScreenViewModelDelegate {
    func updateLocation(location: TaxonLocation)
}

public final class TaxonMapScreenViewModel: ObservableObject {
    public private(set) var locationManager: LocationManager
    public var delegate: TaxonMapScreenViewModelDelegate?
    @Published public var taxonLocation: TaxonLocation?
    
    init(locationManager: LocationManager,
         taxonLocation: TaxonLocation? = nil) {
        self.locationManager = locationManager
        self.taxonLocation = taxonLocation
    }
    
    public func doneTapped(location: TaxonLocation) {
        delegate?.updateLocation(location: location)
    }
    
    public func setMarkerToCurrentLocation() {
        taxonLocation = nil
    }
}
