//
//  NumberOfIndividualsView.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import SwiftUI

struct NumberOfIndividualsView: View {
    var isMaleIndividual: Bool
    var isFemaleIndividual: Bool
    var maleIndividualsTextField: MaterialDesignTextFieldViewModelProtocol
    var femaleIndividualsTextField: MaterialDesignTextFieldViewModelProtocol
    var individualsTextField: MaterialDesignTextFieldViewModelProtocol
    let onMaleTapped: Observer<Void>
    let onFemaleTapped: Observer<Void>
    let sizeOfImage: CGFloat = 20
    
    var body: some View {
        HStack(alignment: .top) {
            HStack {
                CheckView(isChecked: isMaleIndividual,
                          onToggle: { value in
                            onMaleTapped(())
                          })
                Image("male_icon")
                    .resizable()
                    .frame(width: sizeOfImage, height: sizeOfImage)
                    .padding(.leading, -10)
            }
            HStack {
                CheckView(isChecked: isFemaleIndividual,
                          onToggle: { value in
                            onFemaleTapped(())
                          })
                Image("female_icon")
                    .resizable()
                    .frame(width: sizeOfImage, height: sizeOfImage)
                    .padding(.leading, -10)
            }
            VStack {
                if !isMaleIndividual && !isFemaleIndividual {
                    MaterialDesignTextField(viewModel: individualsTextField,
                                            onTextChanged: { text in
                                                
                                            },
                                            textAligment: .left)
                        .frame(height: 50)
                }
                if isMaleIndividual && !isFemaleIndividual {
                    MaterialDesignTextField(viewModel: maleIndividualsTextField,
                                            onTextChanged: { text in
                                                
                                            },
                                            textAligment: .left)
                        .frame(height: 50)
                }
                if !isMaleIndividual && isFemaleIndividual {
                    MaterialDesignTextField(viewModel: femaleIndividualsTextField,
                                            onTextChanged: { text in
                                                
                                            },
                                            textAligment: .left)
                        .frame(height: 50)
                }
                if isMaleIndividual && isFemaleIndividual {
                    MaterialDesignTextField(viewModel: maleIndividualsTextField,
                                            onTextChanged: { text in
                                                
                                            },
                                            textAligment: .left)
                        .frame(height: 50)
                        .padding(.bottom, 20)
                    MaterialDesignTextField(viewModel: femaleIndividualsTextField,
                                            onTextChanged: { text in
                                                
                                            },
                                            textAligment: .left)
                        .frame(height: 50)
                }
            }
            Spacer()
        }
    }

}

struct NumberOfIndividualsView_Previews: PreviewProvider {
    static var previews: some View {
        NumberOfIndividualsView(isMaleIndividual: true,
                                isFemaleIndividual: true,
                                maleIndividualsTextField: MaleIndividualTextField(),
                                femaleIndividualsTextField: FemaleIndividualTextField(),
                                individualsTextField: IndividualTextField(),
                                onMaleTapped: { _ in },
                                onFemaleTapped: { _ in })
    }
}
