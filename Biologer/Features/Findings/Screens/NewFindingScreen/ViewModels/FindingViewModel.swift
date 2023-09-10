//
//  FindingViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 10.9.23..
//

import Foundation

public final class FindingViewModel: ObservableObject {
    public let id: UUID?
    public let findingMode: FindingMode
    public var locationViewModel: NewFindingLocationViewModel
    public var imageViewModel: NewFindingImageViewModel
    public var taxonInfoViewModel: NewFindingInfoViewModel
    public var isUploaded: Bool
    public var dateOfCreation: Date
    
    init(id: UUID? = nil,
         findingMode: FindingMode,
         locationViewModel: NewFindingLocationViewModel,
         imageViewModel: NewFindingImageViewModel,
         taxonInfoViewModel: NewFindingInfoViewModel,
         isUploaded: Bool,
         dateOfCreation: Date) {
        self.id = id
        self.findingMode = findingMode
        self.locationViewModel = locationViewModel
        self.imageViewModel = imageViewModel
        self.taxonInfoViewModel = taxonInfoViewModel
        self.isUploaded = isUploaded
        self.dateOfCreation = dateOfCreation
    }
    
    public func getSelectedObservations() -> [Int] {
        let dbObservations = RealmManager.get(fromEntity: DBObservation.self)
        var ids = [dbObservations[0].id]
        if !imageViewModel.choosenImages.isEmpty {
            ids.append(dbObservations[1].id)
        }
        for (index, observation) in taxonInfoViewModel.observations.enumerated() {
            if observation.isSelected {
                ids.append(dbObservations[index].id)
            }
        }
        return ids
    }
}
