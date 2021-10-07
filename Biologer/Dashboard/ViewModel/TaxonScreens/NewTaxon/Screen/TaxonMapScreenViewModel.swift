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
    @Published public var mapType: MapType = .normal
    private let onMapTypeTapped: Observer<Void>
    
    init(locationManager: LocationManager,
         taxonLocation: TaxonLocation? = nil,
         onMapTypeTapped: @escaping Observer<Void>) {
        self.locationManager = locationManager
        self.taxonLocation = taxonLocation
        self.onMapTypeTapped = onMapTypeTapped
    }
    
    public func doneTapped(location: TaxonLocation) {
        delegate?.updateLocation(location: location)
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
        print("Map Type: \(type.name)")
        self.mapType = type.type
    }
}
