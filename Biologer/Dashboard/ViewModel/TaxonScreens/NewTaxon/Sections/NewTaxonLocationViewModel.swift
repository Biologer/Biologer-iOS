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
    private let onLocationTapped: Observer<Void>
    private let location: LocationManager
    @Published var isLoadingLocation: Bool = true
    @Published var latitude: String = ""
    @Published var longitude: String = ""
    @Published var accuraccy: String = ""
    
    init(location: LocationManager,
         onLocationTapped: @escaping Observer<Void>) {
        self.location = location
        self.onLocationTapped = onLocationTapped
        checkForUpdatingLocation()
    }
    
    public func checkForUpdatingLocation() {
        location.startUpdateingLocation()
        location.onLocationUpdate = { [self] _ in
            self.isLoadingLocation = false
            self.latitude = String(location.latitude)
            self.longitude = String(location.longitude)
            self.accuraccy = String(location.accuracy)
        }
    }
    
    public func locationTapped() {
        location.stopUpdatingLocation()
        onLocationTapped(())
    }
}

// MARK: - Taxon Map Delegate
extension NewTaxonLocationViewModel: TaxonMapScreenViewModelDelegate {
    public func updateLocation(location: TaxonLocation) {
        latitude = String(location.latitude)
        longitude = String(location.longitute)
        accuraccy = (String(location.accuracy))
    }
}
