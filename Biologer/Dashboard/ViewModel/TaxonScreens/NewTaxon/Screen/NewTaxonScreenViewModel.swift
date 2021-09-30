//
//  NewTaxonScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import Foundation

public final class NewTaxonScreenViewModel: ObservableObject {
    @Published public var locationViewModel: NewTaxonLocationViewModel
    @Published public var imageViewModel: NewTaxonImageViewModel
    public var taxonInfoViewModel: NewTaxonInfoViewModel
    public let saveButtonTitle: String = "NewTaxon.btn.save.text".localized
    
    private let onSaveTapped: Observer<Void>
    
    init(locationViewModel: NewTaxonLocationViewModel,
         imageViewModel: NewTaxonImageViewModel,
         taxonInfoViewModel: NewTaxonInfoViewModel,
         onSaveTapped: @escaping Observer<Void>) {
        self.locationViewModel = locationViewModel
        self.imageViewModel = imageViewModel
        self.taxonInfoViewModel = taxonInfoViewModel
        self.onSaveTapped = onSaveTapped
    }
    
    public func saveTapped() {
        onSaveTapped(())
    }
}

// MARK: - Taxon Map Delegate
extension NewTaxonScreenViewModel: TaxonMapScreenViewModelDelegate {
    public func updateLocation(location: TaxonLocation) {
        locationViewModel.latitude = String(location.latitude)
        locationViewModel.longitude = String(location.longitute)
    }
}
