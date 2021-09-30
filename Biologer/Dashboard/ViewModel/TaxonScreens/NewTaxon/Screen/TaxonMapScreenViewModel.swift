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
    private var location: TaxonLocation?
    public var delegate: TaxonMapScreenViewModelDelegate?
    
    init(location: TaxonLocation? = nil) {
        self.location = location
    }
    
    public func doneTapped() {
        if let location = location {
            delegate?.updateLocation(location: location)
        }
    }
}
