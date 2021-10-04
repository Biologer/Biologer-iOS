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
    private let location = LocationManager()
    @Published var isLoadingLocation: Bool
    @Published var latitude: String
    @Published var longitude: String
    @Published var accuraccy: String
    
    init(isLoadingLocatino: Bool,
         latitude: String,
         longitude: String,
         accuraccy: String,
         onLocationTapped: @escaping Observer<Void>) {
        self.isLoadingLocation = isLoadingLocatino
        self.latitude = latitude
        self.longitude = longitude
        self.accuraccy = accuraccy
        self.onLocationTapped = onLocationTapped
        location.onLocationUpdate = { [self] _ in
            self.isLoadingLocation = false
            self.latitude = String(location.latitude)
            self.longitude = String(location.longitude)
            self.accuraccy = String(location.location!.horizontalAccuracy)
        }
    }
    
    public func locationTapped() {
        onLocationTapped(())
    }
}
