//
//  NumberOfIndividualsView.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import SwiftUI

struct NumberOfIndividualsView: View {
    var male: TaxonIndividual
    var female: TaxonIndividual
    var all: TaxonIndividual
    var maleIndividualsTextField: MaterialDesignTextFieldViewModelProtocol
    var femaleIndividualsTextField: MaterialDesignTextFieldViewModelProtocol
    var individualsTextField: MaterialDesignTextFieldViewModelProtocol
    let onMaleTapped: Observer<Void>
    let onFemaleTapped: Observer<Void>
    let sizeOfImage: CGFloat = 20
    
    var body: some View {
        HStack(alignment: .top) {
            HStack {
                CheckView(isChecked: male.isSelected,
                          onToggle: { value in
                            onMaleTapped(())
                          })
                Image("male_icon")
                    .resizable()
                    .frame(width: sizeOfImage, height: sizeOfImage)
                    .padding(.leading, -10)
            }
            HStack {
                CheckView(isChecked: female.isSelected,
                          onToggle: { value in
                            onFemaleTapped(())
                          })
                Image("female_icon")
                    .resizable()
                    .frame(width: sizeOfImage, height: sizeOfImage)
                    .padding(.leading, -10)
            }
            VStack {
                if !male.isSelected && !female.isSelected {
                    MaterialDesignTextField(viewModel: individualsTextField,
                                            keyboardType: .numberPad,
                                            onTextChanged: { text in
                                                all.number = Int(text) ?? 0
                                            },
                                            textAligment: .left)
                        .frame(height: 50)
                }
                if male.isSelected && !female.isSelected {
                    MaterialDesignTextField(viewModel: maleIndividualsTextField,
                                            keyboardType: .numberPad,
                                            onTextChanged: { text in
                                                male.number = Int(text) ?? 0
                                            },
                                            textAligment: .left)
                        .frame(height: 50)
                }
                if !male.isSelected && female.isSelected {
                    MaterialDesignTextField(viewModel: femaleIndividualsTextField,
                                            keyboardType: .numberPad,
                                            onTextChanged: { text in
                                                female.number = Int(text) ?? 0
                                             },
                                            textAligment: .left)
                        .frame(height: 50)
                }
                if male.isSelected && female.isSelected {
                    MaterialDesignTextField(viewModel: maleIndividualsTextField,
                                            keyboardType: .numberPad,
                                            onTextChanged: { text in
                                                male.number = Int(text) ?? 0
                                            },
                                            textAligment: .left)
                        .frame(height: 50)
                        .padding(.bottom, 20)
                    MaterialDesignTextField(viewModel: femaleIndividualsTextField,
                                            keyboardType: .numberPad,
                                            onTextChanged: { text in
                                                female.number = Int(text) ?? 0
                                            },
                                            textAligment: .left)
                        .frame(height: 50)
                }
            }
        }
    }
}

struct NumberOfIndividualsView_Previews: PreviewProvider {
    static var previews: some View {
        NumberOfIndividualsView(male: TaxonIndividual(number: 0),
                                female: TaxonIndividual(number: 0),
                                all: TaxonIndividual(number: 2),
                                maleIndividualsTextField: MaleIndividualTextField(text: ""),
                                femaleIndividualsTextField: FemaleIndividualTextField(text: ""),
                                individualsTextField: IndividualTextField(text: ""),
                                onMaleTapped: { _ in },
                                onFemaleTapped: { _ in })
    }
}
