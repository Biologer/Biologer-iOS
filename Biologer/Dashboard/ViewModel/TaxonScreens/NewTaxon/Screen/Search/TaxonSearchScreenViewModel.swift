//
//  TaxonSearchScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 1.10.21..
//

import Foundation

public protocol TaxonSearchScreenViewModelDelegate {
    func updateTaxonName(taxon: TaxonViewModel)
}

public final class TaxonSearchScreenViewModel: ObservableObject {
    @Published var texons: [TaxonViewModel] = [TaxonViewModel]()
    @Published public private(set) var searchText: String = ""
    private let delegate: TaxonSearchScreenViewModelDelegate?
    private let service: TaxonService
    private let onTaxonTapped: Observer<TaxonViewModel>
    private let onOkTapped: Observer<TaxonViewModel>
    
    init(service: TaxonService,
         delegate: TaxonSearchScreenViewModelDelegate?,
         onTaxonTapped: @escaping Observer<TaxonViewModel>,
         onOkTapped: @escaping Observer<TaxonViewModel>) {
        self.service = service
        self.delegate = delegate
        self.onTaxonTapped = onTaxonTapped
        self.onOkTapped = onOkTapped
    }
    
    public func taxonTapped(taxon: TaxonViewModel) {
        delegate?.updateTaxonName(taxon: taxon)
        onTaxonTapped((taxon))
    }
    
    public func search(search: String) {
        searchText = search
        print("Search is less than 3 character")
        if searchText.count > 2 {
            print("Search is more than 3 character")
            texons = service.getTaxons(by: searchText)
        } else {
            texons.removeAll()
        }
    }
    
    public func okTapped() {
        if searchText != "" {
            let taxon = TaxonViewModel(name: searchText)
            delegate?.updateTaxonName(taxon: taxon)
            onOkTapped((taxon))
        }
    }
}
