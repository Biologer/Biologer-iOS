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
    @Published var nestingTextField: MaterialDesignTextFieldViewModelProtocol = NestingTextField()
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
    
    private let onNestingTapped: Observer<Void>
    private let onDevStageTapped: Observer<Void>
    
    init(observations: [Observation],
         onNestingTapped: @escaping Observer<Void>,
         onDevStageTapped: @escaping Observer<Void>) {
        self.observations = observations
        self.onNestingTapped = onNestingTapped
        self.onDevStageTapped = onDevStageTapped
    }
    
    public func nestingTapped() {
        onNestingTapped(())
    }
    
    public func devStageTapped() {
        onDevStageTapped(())
    }
}
