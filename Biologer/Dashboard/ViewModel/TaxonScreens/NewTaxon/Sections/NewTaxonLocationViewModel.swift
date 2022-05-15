//
//  NewTaxonLocationViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 28.9.21..
//

import SwiftUI

public final class NewTaxonLocationViewModel: ObservableObject {
    public let latitudeTitle: String = "NewTaxon.lb.latitude".localized
    public let longitudeTitle: String = "NewTaxon.lb.longitued".localized
    public let altitudeTitle: String = "NewTaxon.lb.altitude".localized
    public let locationTitle: String = "NewTaxon.lb.locationTitle".localized
    public let accuraccyTitle: String = "NewTaxon.lb.accuracyTitle".localized
    public let setLocationButtonTitle: String = "NewTaxon.btn.setLocation.title".localized
    public let locatioButtonImage: String = "about_icon"
    public let plusIconImage: String = "plus_icon"
    public let waitingForCordiateLabel: String = "NewTaxon.lb.waitingForCordinate".localized
    public let accuracyUnknown: String = "NewTaxon.lb.accuracyUnknown".localized
    public var onLocationTapped: Observer<TaxonLocation?>?
    private let location: LocationManager
    @Published var isLoadingLocation: Bool = true
    @Published var taxonLocation: TaxonLocation?
    
    init(location: LocationManager,
         taxonLocation: TaxonLocation? = nil) {
        self.location = location
        self.taxonLocation = taxonLocation
        if taxonLocation == nil {
            checkForUpdatingLocation()
        }
    }
    
    public var getAltitude: String {
        if let taxonLocation = taxonLocation {
            let altitude = taxonLocation.altitude
            return String(altitude == 0.0 ? accuracyUnknown : "\(altitude.rounded(toPlaces: 1)) m")
        } else {
            return accuracyUnknown
        }
    }
    
    public var getAccuracy: String {
        if let taxonLocarion = taxonLocation {
            let accuracy = taxonLocarion.accuracy
            return accuracy == 0.0 ? accuracyUnknown : "\(accuracy.rounded(toPlaces: 1)) m"
        } else {
            return accuracyUnknown
        }
    }
    
    public func checkForUpdatingLocation() {
        location.onLocationUpdate = { [self] _ in
            self.isLoadingLocation = false
            self.taxonLocation = TaxonLocation(latitude: location.latitude,
                                               longitute: location.longitude,
                                               accuracy: location.accuracy,
                                               altitude: location.altitude)
        }
    }
    
    public func locationTapped() {
        onLocationTapped?((taxonLocation))
    }
}

// MARK: - Taxon Map Delegate
extension NewTaxonLocationViewModel: TaxonMapScreenViewModelDelegate {
    public func updateLocation(location: TaxonLocation) {
        taxonLocation = location
    }
}
