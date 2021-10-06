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

public final class TaxonMapScreenViewModel {
    public private(set) var locationManager: LocationManager
    public var delegate: TaxonMapScreenViewModelDelegate?
    public let taxonLocation: TaxonLocation?
    
    init(locationManager: LocationManager,
         taxonLocation: TaxonLocation? = nil) {
        self.locationManager = locationManager
        self.taxonLocation = taxonLocation
    }
    
    public func doneTapped(location: TaxonLocation) {
        delegate?.updateLocation(location: location)
    }
}
