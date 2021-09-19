//
//  NewTaxonScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import Foundation

public final class NewTaxonScreenViewModel {
    private let onButtonTapped: Observer<Void>
    
    init(onButtonTapped: @escaping Observer<Void>) {
        self.onButtonTapped = onButtonTapped
    }
    
    public func buttonTapped() {
        onButtonTapped(())
    }
}
