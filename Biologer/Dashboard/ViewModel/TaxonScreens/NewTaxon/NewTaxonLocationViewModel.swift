//
//  NewTaxonLocationViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 28.9.21..
//

import Foundation

public final class NewTaxonLocationViewModel: ObservableObject {
    public let locationTitle: String = "NewTaxon.lb.locationTitle".localized
    public let accuraccyTitle: String = "NewTaxon.lb.accuracyTitle".localized
    public let setLocationButtonTitle: String = "NewTaxon.btn.setLocation.title".localized
    public let locatioButtonImage: String = "about_icon"
    public let waitingForCordiateLabel: String = "NewTaxon.lb.waitingForCordinate".localized
    public let accuracyUnknown: String = "NewTaxon.lb.accuracyUnknown".localized
    private let onLocationTapped: Observer<Void>
    @Published var isLoadingLocatino: Bool
    @Published var latitude: String
    @Published var longitude: String
    @Published var accuraccy: String
    
    init(isLoadingLocatino: Bool,
         latitude: String,
         longitude: String,
         accuraccy: String,
         onLocationTapped: @escaping Observer<Void>) {
        self.isLoadingLocatino = isLoadingLocatino
        self.latitude = latitude
        self.longitude = longitude
        self.accuraccy = accuraccy
        self.onLocationTapped = onLocationTapped
    }
    
    public func locationTapped() {
        onLocationTapped(())
    }
}
