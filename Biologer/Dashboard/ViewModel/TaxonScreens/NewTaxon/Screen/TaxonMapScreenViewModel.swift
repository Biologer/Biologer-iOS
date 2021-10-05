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
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }
    
    public func doneTapped(location: TaxonLocation) {
        delegate?.updateLocation(location: location)
    }
}
