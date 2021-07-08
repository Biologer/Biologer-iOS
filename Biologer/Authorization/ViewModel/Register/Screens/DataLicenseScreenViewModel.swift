//
//  DataLicenseScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 8.7.21..
//

import Foundation

public protocol DataLicenseScreenDelegate {
    func get(license: DataLicense)
}

public final class DataLicenseScreenViewModel: DataLicenseScreenLoader {
    var dataLicenses: [DataLicense]
    
    private let onLicenseTapped: Observer<Void>
    private let delegate: DataLicenseScreenDelegate?
    
    init(dataLicenses: [DataLicense],
         delegate: DataLicenseScreenDelegate? = nil,
         onLicenseTapped: @escaping Observer<Void>) {
        self.dataLicenses = dataLicenses
        self.delegate = delegate
        self.onLicenseTapped = onLicenseTapped
    }
    
    func licenseTapped(license: DataLicense) {
        delegate?.get(license: license)
        onLicenseTapped(())
    }
}
