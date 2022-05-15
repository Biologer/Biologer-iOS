//
//  NewTaxonInfoViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 29.9.21..
//

import Foundation

public class Observation: ObservableObject {
    let id: Int
    let name: String
    @Published var isSelected: Bool = false
    
    init(id: Int, name: String, isSelected: Bool = false) {
        self.id = id 
        self.name = name
        self.isSelected = isSelected
    }
}

public final class TaxonIndividual: ObservableObject {
    @Published var isSelected: Bool = false
    var number: Int
    
    init(number: Int, isSelected: Bool = false) {
        self.number = number
        self.isSelected = isSelected
    }
}

public final class NewTaxonInfoViewModel: ObservableObject {
    @Published var taxonNameTextField: MaterialDesignTextFieldViewModelProtocol
    @Published var nestingTextField: MaterialDesignTextFieldViewModelProtocol
    @Published var commentsTextField: MaterialDesignTextFieldViewModelProtocol
    @Published var maleIndividualsTextField: MaterialDesignTextFieldViewModelProtocol
    @Published var femaleIndividualsTextField: MaterialDesignTextFieldViewModelProtocol
    @Published var individualsTextField: MaterialDesignTextFieldViewModelProtocol
    @Published var devStageTextField: MaterialDesignTextFieldViewModelProtocol
    @Published var habitatTextField: MaterialDesignTextFieldViewModelProtocol
    @Published var foundOnTextField: MaterialDesignTextFieldViewModelProtocol
    @Published var fountDeadTextField: MaterialDesignTextFieldViewModelProtocol
    
    @Published var maleIndividual: TaxonIndividual = TaxonIndividual(number: 0)
    @Published var femaleIndividual: TaxonIndividual = TaxonIndividual(number: 0)
    @Published var allIndividual: TaxonIndividual = TaxonIndividual(number: 0)
    @Published var observations: [Observation]
    
    let maleIcon: String = ""
    let femaleIcon: String = ""
    let title: String = "NewTaxon.lb.info.title".localized
    let foundDeadText: String = "NewTaxon.tf.foundDead.text".localized
    @Published var isFoundDead: Bool = false
    
    private(set) var taxon: TaxonViewModel?
    private let settingsStorage: SettingsStorage
    public var onSearchTaxonTapped: Observer<Void>?
    public var onNestingTapped: Observer<NestingAtlasCodeItem?>?
    public var onDevStageTapped: Observer<[DevStageViewModel]?>?
    
    public var shouldPresentAtlasCode: Bool {
        if let taxon = taxon, taxon.isAtlasCode {
            return true
        } else {
            return false
        }
    }
    
    public var shouldPresentDevStage: Bool {
        if let taxon = taxon, taxon.devStages != nil {
            return true
        } else {
            return false
        }
    }
    
    init(observations: [Observation],
         settingsStorage: SettingsStorage,
         taxon: TaxonViewModel? = nil,
         comments: String = "",
         maleIndividual: TaxonIndividual = TaxonIndividual(number: 0),
         femaleIndividual: TaxonIndividual = TaxonIndividual(number: 0),
         allIndividual: TaxonIndividual = TaxonIndividual(number: 0),
         habitat: String = "",
         foundOn: String = "",
         foundDead: String = "") {
        self.observations = observations
        self.taxon = taxon
        self.settingsStorage = settingsStorage
        self.nestingTextField = NestingTextField(text: taxon?.selectedAltasCode?.name ?? "")
        self.taxonNameTextField = TaxonNameTextField(text: taxon?.name ?? "")
        self.commentsTextField = CommentsTextField(text: comments)
        self.maleIndividual = maleIndividual
        self.femaleIndividual = femaleIndividual
        self.allIndividual = allIndividual
        self.maleIndividualsTextField = MaleIndividualTextField(text: String(maleIndividual.number))
        self.femaleIndividualsTextField = FemaleIndividualTextField(text: String(femaleIndividual.number))
        self.individualsTextField = IndividualTextField(text: String(allIndividual.number))
        self.devStageTextField = DevelopmentStageTextField(text: taxon?.selectedDevStage?.name ?? "")
        self.habitatTextField = HabitatlTextField(text: habitat)
        self.foundOnTextField = FoundOnTextField(text: foundOn)
        self.fountDeadTextField = FoundDeadTextField(text: foundDead)
        self.isFoundDead = foundDead == "" ? false : true
    }
    
    public func searchTaxon() {
        onSearchTaxonTapped?(())
    }
    
    public func nestingTapped() {
        onNestingTapped?((taxon?.selectedAltasCode))
    }
    
    public func devStageTapped() {
        onDevStageTapped?((taxon?.devStages))
    }
    
    public func maleTapped() {
        maleIndividual.isSelected.toggle()
        if !maleIndividual.isSelected {
            maleIndividual.number = 1
            maleIndividualsTextField.text = String(maleIndividual.number)
        }
    }
    
    public func femaleTapped() {
        femaleIndividual.isSelected.toggle()
        if !femaleIndividual.isSelected {
            femaleIndividual.number = 1
            femaleIndividualsTextField.text = String(femaleIndividual.number)
        }
    }
    
    public func getGender() -> String {
        if maleIndividual.isSelected {
            return "male"
        } else if femaleIndividual.isSelected {
            return "female"
        } else {
            return ""
        }
    }
    
    public func getGenderIndividuals() -> Int {
        if maleIndividual.isSelected {
            return maleIndividual.number
        } else if femaleIndividual.isSelected {
            return femaleIndividual.number
        } else {
            return 1
        }
    }
}

extension NewTaxonInfoViewModel: TaxonSearchScreenViewModelDelegate {
    public func updateTaxonName(taxon: TaxonViewModel) {
        taxonNameTextField.text = taxon.name
        self.taxon = taxon
        if let settings = settingsStorage.getSettings(), settings.setAdultByDefault, let adultDevStage = taxon.devStages?.last {
            devStageTextField.text = adultDevStage.name
            self.taxon?.selectedDevStage = adultDevStage
        }
    }
}

extension NewTaxonInfoViewModel: NewTaxonDevStageScreenViewModelDelegate {
    public func updateDevStage(devStageViewModel: DevStageViewModel) {
        devStageTextField.text = devStageViewModel.name
        self.taxon?.selectedDevStage = devStageViewModel
    }
}

extension NewTaxonInfoViewModel: NestingAtlasCodeScreenViewModelDelegate {
    public func updateNestingCode(code: NestingAtlasCodeItem) {
        taxon?.selectedAltasCode = code
        nestingTextField.text = code.name
    }
}
