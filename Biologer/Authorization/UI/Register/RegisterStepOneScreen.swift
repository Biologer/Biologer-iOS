//
//  RegisterStepOneScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import SwiftUI

protocol RegisterStepOneScreenLoader: ObservableObject {
    var userNameTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol { get set }
    var lastNameTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol { get set }
    var institutionTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol { get set }
    var buttonTitle: String { get }
    func nextButtonTapped()
}

struct RegisterStepOneScreen<ScreenLoader>: View where ScreenLoader: RegisterStepOneScreenLoader {
    
    @ObservedObject var loader: ScreenLoader
    
    private let topSpacingTextField: CGFloat = 10
    
    var body: some View {
        ScrollView {
            VStack {
                MaterialDesignTextField(viewModel: loader.userNameTextFieldViewModel,
                                        onTextChanged: { text in
                                            
                                        })
                    .padding(.top, topSpacingTextField)
                MaterialDesignTextField(viewModel: loader.lastNameTextFieldViewModel,
                                        onTextChanged: { text in
                                            
                                        })
                    .padding(.top, topSpacingTextField)
                MaterialDesignTextField(viewModel: loader.institutionTextFieldViewModel,
                                        onTextChanged: { text in
                                            
                                        })
                    .padding(.top, topSpacingTextField)
                LoginButton(title: loader.buttonTitle,
                            onTapped: { _ in
                                loader.nextButtonTapped()
                            })
                    .padding(.top, 30)
                
                LoginButton(title: loader.buttonTitle,
                            onTapped: { _ in
                                loader.nextButtonTapped()
                            })
            }
        }
        .padding()
    }
}

struct RegisterStepOneScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegisterStepOneScreen(loader: StubRegisterStepScreenViewModel())
    }
    
    private class StubRegisterStepScreenViewModel: RegisterStepOneScreenLoader {
        var userNameTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = NameTextFieldViewModel()
        var lastNameTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = SurnameTextFieldViewModel()
        var institutionTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = InsititutionTextFieldViewModel()
        var buttonTitle = "Next"
        func nextButtonTapped() {}
    }
}