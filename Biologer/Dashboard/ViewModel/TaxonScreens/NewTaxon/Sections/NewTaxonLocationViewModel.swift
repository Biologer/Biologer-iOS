//
//  NewTaxonLocationViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 28.9.21..
//

import SwiftUI

public final class NewTaxonLocationViewModel: ObservableObject {
    public let locationTitle: String = "NewTaxon.lb.locationTitle".localized
    public let accuraccyTitle: String = "NewTaxon.lb.accuracyTitle".localized
    public let setLocationButtonTitle: String = "NewTaxon.btn.setLocation.title".localized
    public let locatioButtonImage: String = "about_icon"
    public let waitingForCordiateLabel: String = "NewTaxon.lb.waitingForCordinate".localized
    public let accuracyUnknown: String = "NewTaxon.lb.accuracyUnknown".localized
    private let onLocationTapped: Observer<TaxonLocation?>
    private let location: LocationManager
    @Published var isLoadingLocation: Bool = true
    @Published var taxonLocation: TaxonLocation?
    
    init(location: LocationManager,
         taxonLocation: TaxonLocation? = nil,
         onLocationTapped: @escaping Observer<TaxonLocation?>) {
        self.location = location
        self.onLocationTapped = onLocationTapped
        self.taxonLocation = taxonLocation
        checkForUpdatingLocation()
    }
    
    public func checkForUpdatingLocation() {
        location.startUpdateingLocation()
        location.onLocationUpdate = { [self] _ in
            self.isLoadingLocation = false
            self.taxonLocation = TaxonLocation(latitude: location.latitude,
                                               longitute: location.longitude,
                                               accuracy: location.accuracy,
                                               altitude: location.altitude)
        }
    }
    
    public func locationTapped() {
        //location.stopUpdatingLocation()
        onLocationTapped((taxonLocation))
    }
}

// MARK: - Taxon Map Delegate
extension NewTaxonLocationViewModel: TaxonMapScreenViewModelDelegate {
    public func updateLocation(location: TaxonLocation) {
        taxonLocation = location
    }
}
