//
//  NewTaxonInfoView.swift
//  Biologer
//
//  Created by Nikola Popovic on 29.9.21..
//

import SwiftUI

struct NewTaxonInfoView: View {
    
    @ObservedObject var viewModel: NewTaxonInfoViewModel
    
    var body: some View {
        VStack {
            MaterialDesignTextField(viewModel: viewModel.taxonNameTextField,
                                    onTextChanged: { text in
                                        
                                    },
                                    textAligment: .left)
                .frame(height: 50)
                .padding(.bottom, 20)
            
            MaterialDesignTextField(viewModel: viewModel.nestingTextField,
                                    onTextChanged: { text in
                                        
                                    },
                                    textAligment: .left)
                .frame(height: 50)
                .padding(.bottom, 20)
            
            MaterialDesignTextField(viewModel: viewModel.commentsTextField,
                                    onTextChanged: { text in
                                        
                                    },
                                    textAligment: .left)
                .frame(height: 50)
                .padding(.bottom, 20)
            
            NumberOfIndividualsView(isMaleIndividual: viewModel.isMaleIndividual,
                                    isFemaleIndividual: viewModel.isFemaleIndividual,
                                    maleIndividualsTextField: viewModel.maleIndividualsTextField,
                                    femaleIndividualsTextField: viewModel.femaleIndividualsTextField,
                                    individualsTextField: viewModel.individualsTextField,
                                    onMaleTapped: { _ in
                                        viewModel.isMaleIndividual.toggle()
                                    },
                                    onFemaleTapped: { _ in
                                        viewModel.isFemaleIndividual.toggle()
                                    })
            Spacer()
        }
        
        Spacer()
    }
}

struct NumberOfIndividualsView: View {
    
    var isMaleIndividual: Bool
    var isFemaleIndividual: Bool
    var maleIndividualsTextField: MaterialDesignTextFieldViewModelProtocol
    var femaleIndividualsTextField: MaterialDesignTextFieldViewModelProtocol
    var individualsTextField: MaterialDesignTextFieldViewModelProtocol
    let onMaleTapped: Observer<Void>
    let onFemaleTapped: Observer<Void>
    
    var body: some View {
        HStack {
            CheckView(isChecked: isMaleIndividual,
                      onToggle: { value in
                        onMaleTapped(())
                      })
            CheckView(isChecked: isFemaleIndividual,
                      onToggle: { value in
                        onFemaleTapped(())
                      })
            
            VStack {
                if !isMaleIndividual && !isFemaleIndividual {
                    MaterialDesignTextField(viewModel: individualsTextField,
                                            onTextChanged: { text in
                                                
                                            },
                                            textAligment: .left)
                        .frame(height: 50)
                        .padding(.bottom, 20)
                    if isMaleIndividual && !isFemaleIndividual {
                        MaterialDesignTextField(viewModel: maleIndividualsTextField,
                                                onTextChanged: { text in
                                                    
                                                },
                                                textAligment: .left)
                            .frame(height: 50)
                            .padding(.bottom, 20)
                    }
                    if !isMaleIndividual && isFemaleIndividual {
                        MaterialDesignTextField(viewModel: femaleIndividualsTextField,
                                                onTextChanged: { text in
                                                    
                                                },
                                                textAligment: .left)
                            .frame(height: 50)
                            .padding(.bottom, 20)
                    }
                }
            }
            Spacer()
        }
    }
    
}

struct NewTaxonInfoView_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = NewTaxonInfoViewModel(observations: [Observation(name: "Call"),
                                                             Observation(name: "Exuviae")],
                                              onNestingTapped: { _ in },
                                              onDevStageTapped: { _ in })
        
        NewTaxonInfoView(viewModel: viewModel)
    }
}
