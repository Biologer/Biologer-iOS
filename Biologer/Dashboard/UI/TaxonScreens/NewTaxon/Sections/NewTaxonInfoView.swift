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
            
            Button(action: {
                
            }, label: {
                MaterialDesignTextField(viewModel: viewModel.nestingTextField,
                                        onTextChanged: { text in
                                            
                                        },
                                        textAligment: .left)
                    .frame(height: 50)
                    .padding(.bottom, 20)
            })
            
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
                .padding(.bottom, 5)
            
            ObservationsView(observations: viewModel.observations,
                             onObservationTapped: { index in
                                viewModel.objectWillChange.send()
                                viewModel.observations[index].isSelected.toggle()
                             })
            
            Button(action: {
                
            }, label: {
                MaterialDesignTextField(viewModel: viewModel.devStageTextField,
                                        onTextChanged: { text in
                                            
                                        },
                                        textAligment: .left)
                    .frame(height: 50)
                    .padding(.bottom, 20)
            })
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
        
        let viewModel = NewTaxonInfoViewModel(observations: [Observation(name: "Call"),
                                                             Observation(name: "Exuviae")],
                                              onSearchTaxonTapped: { _ in},
                                              onNestingTapped: { _ in },
                                              onDevStageTapped: { _ in })
        
        NewTaxonInfoView(viewModel: viewModel)
    }
}
