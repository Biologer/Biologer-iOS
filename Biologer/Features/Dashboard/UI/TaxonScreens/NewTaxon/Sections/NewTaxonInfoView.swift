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
            Button(action: {
                viewModel.searchTaxon()
            }, label: {
                MaterialDesignTextField(viewModel: viewModel.taxonNameTextField,
                                        onTextChanged: { text in

                                        },
                                        onIconTapped: { _ in
                                            
                                        },
                                        textAligment: .left)
                    .frame(height: 50)
                    .padding(.bottom, 20)
            })
            
            if viewModel.shouldPresentAtlasCode {
                Button(action: {
                    viewModel.nestingTapped()
                }, label: {
                    MaterialDesignTextArea(viewModel: viewModel.nestingTextField,
                                            onTextChanged: { text in
                                                
                                            },
                                            textAligment: .left)
                        .padding(.bottom, 20)
                })
            }
            
            MaterialDesignTextArea(viewModel: viewModel.commentsTextField,
                                    onTextChanged: { text in
                                        
                                    },
                                    textAligment: .left)
                .padding(.bottom, 20)
            
            NumberOfIndividualsView(male: viewModel.maleIndividual,
                                    female: viewModel.femaleIndividual,
                                    all: viewModel.allIndividual,
                                    maleIndividualsTextField: viewModel.maleIndividualsTextField,
                                    femaleIndividualsTextField: viewModel.femaleIndividualsTextField,
                                    individualsTextField: viewModel.individualsTextField,
                                    onMaleTapped: { _ in
                                        viewModel.maleTapped()
                                        viewModel.objectWillChange.send()
                                    },
                                    onFemaleTapped: { _ in
                                        viewModel.femaleTapped()
                                        viewModel.objectWillChange.send()
                                    })
                .padding(.bottom, 5)
            
            ObservationsView(observations: viewModel.observations,
                             onObservationTapped: { index in
                                viewModel.objectWillChange.send()
                                viewModel.observations[index].isSelected.toggle()
                             })
            
            if viewModel.shouldPresentDevStage {
                Button(action: {
                    viewModel.devStageTapped()
                }, label: {
                    MaterialDesignTextField(viewModel: viewModel.devStageTextField,
                                            onTextChanged: { text in
                                                
                                            },
                                            textAligment: .left)
                        .frame(height: 50)
                        .padding(.bottom, 20)
                })
            }

            MaterialDesignTextField(viewModel: viewModel.habitatTextField,
                                    onTextChanged: { text in
                                        
                                    },
                                    textAligment: .left)
                .frame(height: 50)
                .padding(.bottom, 20)
            
            MaterialDesignTextField(viewModel: viewModel.foundOnTextField,
                                    onTextChanged: { text in
                                        
                                    },
                                    textAligment: .left)
                .frame(height: 50)
                .padding(.bottom, 20)
            FoundDeadView(isCehcked: viewModel.isFoundDead,
                          checkText: viewModel.foundDeadText,
                          onCheckMarkTapped: { _ in
                            viewModel.isFoundDead.toggle()
                          },
                          textFieldViewModel: viewModel.fountDeadTextField)
            Spacer()
        }
    }
}

struct NewTaxonInfoView_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = NewTaxonInfoViewModel(observations: [Observation(id: 1, name: "Call"),
                                                             Observation(id: 2, name: "Exuviae")], settingsStorage: UserDefaultsSettingsStorage())
        
        NewTaxonInfoView(viewModel: viewModel)
    }
}
