//
//  NewTaxonInfoViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 29.9.21..
//

import Foundation

public class Observation: ObservableObject {
    let id = UUID()
    let name: String
    @Published var isSelected: Bool = false
    
    init(name: String) {
        self.name = name
    }
}

public final class NewTaxonInfoViewModel: ObservableObject {
    @Published var taxonNameTextField: MaterialDesignTextFieldViewModelProtocol = TaxonNameTextField()
    @Published var nestingTextField: MaterialDesignTextFieldViewModelProtocol = NestingTextField(text: "")
    @Published var commentsTextField: MaterialDesignTextFieldViewModelProtocol = CommentsTextField()
    @Published var maleIndividualsTextField: MaterialDesignTextFieldViewModelProtocol = MaleIndividualTextField()
    @Published var femaleIndividualsTextField: MaterialDesignTextFieldViewModelProtocol = FemaleIndividualTextField()
    @Published var individualsTextField: MaterialDesignTextFieldViewModelProtocol  = IndividualTextField()
    @Published var devStageTextField: MaterialDesignTextFieldViewModelProtocol  = DevelopmentStageTextField()
    @Published var habitatTextField: MaterialDesignTextFieldViewModelProtocol  = HabitatlTextField()
    @Published var foundOnTextField: MaterialDesignTextFieldViewModelProtocol  = FoundOnTextField()
    @Published var fountDeadTextField: MaterialDesignTextFieldViewModelProtocol  = FoundDeadTextField()
    @Published var isMaleIndividual: Bool = false
    @Published var isFemaleIndividual: Bool = false
    @Published var isFoundDead: Bool = false
    @Published var observations: [Observation]
    
    let maleIcon: String = ""
    let femaleIcon: String = ""
    let title: String = "NewTaxon.lb.info.title".localized
    let foundDeadText: String = "NewTaxon.tf.foundDead.text".localized
    
    private var nestingAltasCode: NestingAtlasCodeItem?
    private let onSearchTaxonTapped: Observer<Void>
    private let onNestingTapped: Observer<NestingAtlasCodeItem?>
    private let onDevStageTapped: Observer<Void>
    
    init(observations: [Observation],
         onSearchTaxonTapped: @escaping Observer<Void>,
         onNestingTapped: @escaping Observer<NestingAtlasCodeItem?>,
         onDevStageTapped: @escaping Observer<Void>) {
        self.observations = observations
        self.onSearchTaxonTapped = onSearchTaxonTapped
        self.onNestingTapped = onNestingTapped
        self.onDevStageTapped = onDevStageTapped
    }
    
    public func searchTaxon() {
        onSearchTaxonTapped(())
    }
    
    public func nestingTapped() {
        onNestingTapped((nestingAltasCode))
    }
    
    public func devStageTapped() {
        onDevStageTapped(())
    }
}

extension NewTaxonInfoViewModel: TaxonSearchScreenViewModelDelegate {
    public func updateTaxonName(taxon: TaxonViewModel) {
        taxonNameTextField.text = taxon.name
    }
}

extension NewTaxonInfoViewModel: NewTaxonDevStageScreenViewModelDelegate {
    public func updateDevStage(devStageViewModel: DevStageViewModel) {
        devStageTextField.text = devStageViewModel.name
    }
}

extension NewTaxonInfoViewModel: NestingAtlasCodeScreenViewModelDelegate {
    public func updateNestingCode(code: NestingAtlasCodeItem) {
        nestingAltasCode = code
        nestingTextField = NestingTextField(text: code.name)
    }
}
