//
//  RegisterStepOneScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import SwiftUI

protocol RegisterStepOneScreenLoader: ObservableObject {
    var userNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol { get set }
    var lastNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol { get set }
    var institutionTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol { get set }
    var buttonTitle: String { get }
    func nextButtonTapped()
}

struct RegisterStepOneScreen<ScreenLoader>: View where ScreenLoader: RegisterStepOneScreenLoader {
    
    @ObservedObject var loader: ScreenLoader
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear
                    .padding(.top, 10)
                MaterialDesignTextField(viewModel: loader.userNameTextFieldViewModel,
                                        onTextChanged: { text in
                                            
                                        },
                                        textAligment: .left)
                MaterialDesignTextField(viewModel: loader.lastNameTextFieldViewModel,
                                        onTextChanged: { text in
                                            
                                        },
                                        textAligment: .left)
                MaterialDesignTextField(viewModel: loader.institutionTextFieldViewModel,
                                        onTextChanged: { text in
                                            
                                        },
                                        textAligment: .left)
                BiologerButton(title: loader.buttonTitle,
                            onTapped: { _ in
                                loader.nextButtonTapped()
                            })
                    .padding(.top, 20)
            }
            .padding(.horizontal, 30)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct RegisterStepOneScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegisterStepOneScreen(loader: StubRegisterStepScreenViewModel())
    }
    
    private class StubRegisterStepScreenViewModel: RegisterStepOneScreenLoader {
        var userNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = NameTextFieldViewModel()
        var lastNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = SurnameTextFieldViewModel()
        var institutionTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = InsititutionTextFieldViewModel()
        var buttonTitle = "Next"
        func nextButtonTapped() {}
    }
}