//
//  MapTypeScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 6.10.21..
//

import Foundation

public enum MapType {
    case normal
    case hybrid
    case terrain
    case satellite
}

public final class MapTypeViewModel {
    let id = UUID()
    let name: String
    let type: MapType
    
    init(name: String,
         type: MapType) {
        self.name = name
        self.type = type
    }
}

public protocol MapTypeScreenViewModelDelegate {
    func updateMapType(type: MapTypeViewModel)
}

public class MapTypeScreenViewModel {
    var mapTypes: [MapTypeViewModel] = [MapTypeViewModel(name: "NewTaxon.mapType.normal.title".localized, type: .normal),
                                        MapTypeViewModel(name: "NewTaxon.mapType.hybrid.title".localized, type: .hybrid),
                                        MapTypeViewModel(name: "NewTaxon.mapType.terrain.title".localized, type: .terrain),
                                        MapTypeViewModel(name: "NewTaxon.mapType.satellite.title".localized, type: .satellite)]
    public var delegate: MapTypeScreenViewModelDelegate?
    private let onTypeTapped: Observer<MapTypeViewModel>
    
    init(delegate: MapTypeScreenViewModelDelegate?,
         onTypeTapped: @escaping Observer<MapTypeViewModel>) {
        self.delegate = delegate
        self.onTypeTapped = onTypeTapped
    }
    
    public func typeTapped(type: MapTypeViewModel) {
        delegate?.updateMapType(type: type)
        onTypeTapped((type))
    }
}
