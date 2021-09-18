//
//  DataLicenseScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 8.7.21..
//

import Foundation

public protocol DataLicenseScreenDelegate {
    func get(license: CheckMarkItem)
}

public final class CheckMarkScreenViewModel: CheckMarkScreenLoader {
    var dataLicenses: [CheckMarkItem]
    
    private let onLicenseTapped: Observer<CheckMarkItem>
    private let delegate: DataLicenseScreenDelegate?
    
    init(dataLicenses: [CheckMarkItem],
         selectedDataLicense: CheckMarkItem,
         delegate: DataLicenseScreenDelegate? = nil,
         onLicenseTapped: @escaping Observer<CheckMarkItem>) {
        self.dataLicenses = dataLicenses
        self.delegate = delegate
        self.onLicenseTapped = onLicenseTapped
        updateSelectedViewModel(license: selectedDataLicense)
    }
    
    func licenseTapped(license: CheckMarkItem) {
        delegate?.get(license: license)
        onLicenseTapped((license))
    }
    
    public func updateSelectedViewModel(license: CheckMarkItem) {

        for (index, lic) in dataLicenses.enumerated() {
            if lic.id == license.id {
                dataLicenses[index].changeIsSelected(value: true)
            } else {
                dataLicenses[index].changeIsSelected(value: false)
            }
        }
    }
}
