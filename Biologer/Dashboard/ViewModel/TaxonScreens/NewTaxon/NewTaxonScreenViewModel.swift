//
//  NewTaxonScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import Foundation

public final class NewTaxonScreenViewModel {
    private let onSaveTapped: Observer<Void>
    public let saveButtonTitle: String = "NewTaxon.btn.save.text".localized
    
    init(onSaveTapped: @escaping Observer<Void>) {
        self.onSaveTapped = onSaveTapped
    }
    
    public func saveTapped() {
        onSaveTapped(())
    }
}
