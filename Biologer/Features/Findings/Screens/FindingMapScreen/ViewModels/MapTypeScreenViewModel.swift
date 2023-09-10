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

public protocol MapTypeScreenViewModelDelegate {
    func updateMapType(type: MapTypeViewModel)
}

public class MapTypeScreenViewModel {
    var mapTypes: [MapTypeViewModel] = MapTypeViewModelFactory.getViewModels()
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
