//
//  NewFindingScreenViewModel.swift
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

public final class NewFindingScreenViewModel: ObservableObject {
    @Published public var findingViewModel: FindingViewModel
    public let saveButtonTitle: String = "NewTaxon.btn.save.text".localized
    
    public var onSaveTapped: Observer<[FindingViewModel]>?
    public var onFindingIsNotValid: Observer<String>?
    
    private let settingsStorage: SettingsStorage
    
    init(findingViewModel: FindingViewModel,
         settingsStorage: SettingsStorage) {
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
        let maleTaxonInfo = NewFindingInfoViewModel(observations: taxonInfoViewModel.observations,
                                                  settingsStorage: settingsStorage,
                                                  taxon: taxonInfoViewModel.taxon,
                                                  comments: taxonInfoViewModel.commentsTextField.text,
                                                  maleIndividual: taxonInfoViewModel.maleIndividual,
                                                  femaleIndividual: FindingIndividual(number: 0, isSelected: false),
                                                  allIndividual: FindingIndividual(number: 0, isSelected: false),
                                                  habitat: taxonInfoViewModel.habitatTextField.text,
                                                  foundOn: taxonInfoViewModel.foundOnTextField.text,
                                                  foundDead: taxonInfoViewModel.foundOnTextField.text)
        let femaleTaxonInfo = NewFindingInfoViewModel(observations: taxonInfoViewModel.observations,
                                                    settingsStorage: settingsStorage,
                                                    taxon: taxonInfoViewModel.taxon,
                                                    comments: taxonInfoViewModel.commentsTextField.text,
                                                    maleIndividual: FindingIndividual(number: 0, isSelected: false),
                                                    femaleIndividual: taxonInfoViewModel.femaleIndividual,
                                                    allIndividual: FindingIndividual(number: 0, isSelected: false),
                                                    habitat: taxonInfoViewModel.habitatTextField.text,
                                                    foundOn: taxonInfoViewModel.foundOnTextField.text,
                                                    foundDead: taxonInfoViewModel.foundOnTextField.text)
        let maleFindingViewModel = FindingViewModel(findingMode: findingViewModel.findingMode,
                                                    locationViewModel: findingViewModel.locationViewModel,
                                                    imageViewModel: findingViewModel.imageViewModel,
                                                    taxonInfoViewModel: maleTaxonInfo,
                                                    isUploaded: false,
                                                    dateOfCreation: findingViewModel.dateOfCreation)
        let femaleFindingViewModel = FindingViewModel(findingMode: findingViewModel.findingMode,
                                                      locationViewModel: findingViewModel.locationViewModel,
                                                      imageViewModel: findingViewModel.imageViewModel,
                                                      taxonInfoViewModel: femaleTaxonInfo,
                                                      isUploaded: false,
                                                      dateOfCreation: findingViewModel.dateOfCreation)
        return [maleFindingViewModel, femaleFindingViewModel]
    }
}
