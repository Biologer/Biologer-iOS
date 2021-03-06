//
//  RegisterStepTwoScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import SwiftUI

protocol RegisterStepTwoScreenLoader: ObservableObject {
    var emailTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol { get set }
    var passwordTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol { get set }
    var repeatPasswordTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol { get set }
    var buttonTitle: String { get }
    func nextButtonTapped()
}

struct RegisterStepTwoScreen<ScreenLoader>: View where ScreenLoader: RegisterStepTwoScreenLoader {
    
    @ObservedObject var loader: ScreenLoader
    
    var body: some View {
        ScrollView {
            VStack() {
                MaterialDesignTextField(viewModel: loader.emailTextFieldViewModel,
                                        onTextChanged: { text in
                                            
                                        },
                                        textAligment: .left)
                    .padding()
                MaterialDesignTextField(viewModel: loader.passwordTextFieldViewModel,
                                        onTextChanged: { text in
                                            
                                        },
                                        onIconTapped: { _ in
                                            loader.toggleIsCodeEntryPassword()
                                        },
                                        textAligment: .left)
                    .padding()
                MaterialDesignTextField(viewModel: loader.repeatPasswordTextFieldViewModel,
                                        onTextChanged: { text in
                                            
                                        },
                                        onIconTapped: { _ in
                                            loader.toggleIsCodeEntryRepeatPassword()
                                        },
                                        textAligment: .left)
                    .padding()
                BiologerButton(title: loader.buttonTitle,
                            onTapped: { _ in
                                loader.nextButtonTapped()
                            })
                    .padding(.top, 20)
            }
        }
        .padding(.all, 30)
    }
}

struct RegisterStepTwoScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegisterStepTwoScreen(loader: StubRegisterTwoScreenViewModel())
    }
    
    public class StubRegisterTwoScreenViewModel: RegisterStepTwoScreenLoader {
        var emailTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = EmailTextFieldViewModel()
        var passwordTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = RegisterPasswordTextFieldViewModel()
        var repeatPasswordTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = RepeatPasswordTextFieldViewModel()
        var buttonTitle = "Next"
        func nextButtonTapped() {}
    }
}
