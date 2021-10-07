//
//  ListOfFindingsScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.6.21..
//

import Foundation

public enum SideMenuMainScreenPreview {
    case regular([Finding])
    case iregular(String)
}

public final class ListOfFindingsScreenViewModel: ListOfFindingsScreenLoader, ObservableObject {
    var onDeleteFindingTapped: Observer<Finding>
    var onNewItemTapped: Observer<Void>
    var onItemTapped: Observer<Finding>
    
    @Published var preview: SideMenuMainScreenPreview = .iregular("No Data")
    
    init(onNewItemTapped: @escaping Observer<Void>,
         onItemTapped: @escaping Observer<Finding>,
         onDeleteFindingTapped: @escaping Observer<Finding>) {
        self.onNewItemTapped = onNewItemTapped
        self.onItemTapped = onItemTapped
        self.onDeleteFindingTapped = onDeleteFindingTapped
    }
    
    func getData() {
        // MARK: - Get data from API or DB
        preview = .regular([Finding(id: 1, taxon: "Zerynthia polyxena", developmentStage: "Larva"),
                            Finding(id: 2, taxon: "Salamandra salamandra", developmentStage: "Adult"),
                            Finding(id: 3, taxon: "Salamandra salamandra", developmentStage: "Adult")])

    }
}
