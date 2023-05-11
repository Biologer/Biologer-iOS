//
//  NewTaxonScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import Foundation
import RealmSwift

public enum FindingMode {
    case create
    case edit
}

public final class FindingViewModel: ObservableObject {
    public let id: UUID?
    public let findingMode: FindingMode
    public var locationViewModel: NewTaxonLocationViewModel
    public var imageViewModel: NewTaxonImageViewModel
    public var taxonInfoViewModel: NewTaxonInfoViewModel
    public var isUploaded: Bool
    public var dateOfCreation: Date
    
    init(id: UUID? = nil,
         findingMode: FindingMode,
         locationViewModel: NewTaxonLocationViewModel,
         imageViewModel: NewTaxonImageViewModel,
         taxonInfoViewModel: NewTaxonInfoViewModel,
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

public final class NewTaxonScreenViewModel: ObservableObject {
    @Published public var findingViewModel: FindingViewModel
    public let saveButtonTitle: String = "NewTaxon.btn.save.text".localized
    
    public var onSaveTapped: Observer<[FindingViewModel]>?
    public var onFindingIsNotValid: Observer<String>?
    
    private let settingsStorage: SettingsStorage
    
    init(findingViewModel: FindingViewModel, settingsStorage: SettingsStorage) {
        self.findingViewModel = findingViewModel
        self.settingsStorage = settingsStorage
    }
    
    public func saveTapped() {
        findingViewModel.isUploaded = false
        if isFindingValid() {
            if findingViewModel.taxonInfoViewModel.maleIndividual.isSelected &&
                findingViewModel.taxonInfoViewModel.femaleIndividual.isSelected {
                let findingViewModels = createSameFindingWithDifferentGender(findingViewModel: findingViewModel)
                onSaveTapped?((findingViewModels))
            } else {
                onSaveTapped?(([findingViewModel]))
            }
        }
    }
    
    private func isFindingValid() -> Bool {
        if findingViewModel.taxonInfoViewModel.taxonNameTextField.text == "" {
            onFindingIsNotValid?(("NewTaxon.popUpError.description.title.taxonNameRequired".localized))
            return false
        } else if findingViewModel.taxonInfoViewModel.getGenderIndividuals() == 0 {
            onFindingIsNotValid?(("NewTaxon.popUpError.description.title.minimumNumberOfIndividualsIsOne".localized))
            return false
        } else {
            return true
        }
    }
    
    private func createSameFindingWithDifferentGender(findingViewModel: FindingViewModel) -> [FindingViewModel] {
        let taxonInfoViewModel = findingViewModel.taxonInfoViewModel
        let maleTaxonInfo = NewTaxonInfoViewModel(observations: taxonInfoViewModel.observations,
                                                  settingsStorage: settingsStorage,
                                                  taxon: taxonInfoViewModel.taxon,
                                                  comments: taxonInfoViewModel.commentsTextField.text,
                                                  maleIndividual: taxonInfoViewModel.maleIndividual,
                                                  femaleIndividual: TaxonIndividual(number: 0, isSelected: false),
                                                  allIndividual: TaxonIndividual(number: 0, isSelected: false),
                                                  habitat: taxonInfoViewModel.habitatTextField.text,
                                                  foundOn: taxonInfoViewModel.foundOnTextField.text,
                                                  foundDead: taxonInfoViewModel.foundOnTextField.text)
        let femaleTaxonInfo = NewTaxonInfoViewModel(observations: taxonInfoViewModel.observations,
                                                    settingsStorage: settingsStorage,
                                                    taxon: taxonInfoViewModel.taxon,
                                                    comments: taxonInfoViewModel.commentsTextField.text,
                                                    maleIndividual: TaxonIndividual(number: 0, isSelected: false),
                                                    femaleIndividual: taxonInfoViewModel.femaleIndividual,
                                                    allIndividual: TaxonIndividual(number: 0, isSelected: false),
                                                    habitat: taxonInfoViewModel.habitatTextField.text,
                                                    foundOn: taxonInfoViewModel.foundOnTextField.text,
                                                    foundDead: taxonInfoViewModel.foundOnTextField.text)
        let maleFindingViewModel = FindingViewModel(findingMode: findingViewModel.findingMode,
                                                    locationViewModel: findingViewModel.locationViewModel,
                                                    imageViewModel: findingViewModel.imageViewModel,
                                                    taxonInfoViewModel: maleTaxonInfo,
                                                    isUploaded: false,
                                                    dateOfCreation: Date())
        let femaleFindingViewModel = FindingViewModel(findingMode: findingViewModel.findingMode,
                                                      locationViewModel: findingViewModel.locationViewModel,
                                                      imageViewModel: findingViewModel.imageViewModel,
                                                      taxonInfoViewModel: femaleTaxonInfo,
                                                      isUploaded: false,
                                                      dateOfCreation: Date())
        return [maleFindingViewModel, femaleFindingViewModel]
    }
}
