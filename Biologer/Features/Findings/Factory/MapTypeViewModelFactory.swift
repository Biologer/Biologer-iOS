//
//  MapTypeViewModelFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 10.9.23..
//

import Foundation

public final class MapTypeViewModelFactory {
    static func getViewModels() -> [MapTypeViewModel] {
        return [MapTypeViewModel(name: "NewTaxon.mapType.normal.title".localized,
                                 type: .normal),
                MapTypeViewModel(name: "NewTaxon.mapType.hybrid.title".localized,
                                 type: .hybrid),
                MapTypeViewModel(name: "NewTaxon.mapType.terrain.title".localized,
                                 type: .terrain),
                MapTypeViewModel(name: "NewTaxon.mapType.satellite.title".localized,
                                 type: .satellite)]
    }
}
