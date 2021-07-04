//
//  RegisterStepTwoScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import SwiftUI

protocol RegisterStepTwoScreenLoader: ObservableObject {
    var emailTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol { get set }
    var passwordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol { get set }
    var repeatPasswordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol { get set }
    var buttonTitle: String { get }
    func nextButtonTapped()
}

struct RegisterStepTwoScreen<ScreenLoader>: View where ScreenLoader: RegisterStepTwoScreenLoader {
    
    @ObservedObject var loader: ScreenLoader
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                MaterialDesignTextField(viewModel: loader.emailTextFieldViewModel,
                                        onTextChanged: { text in
                                            
                                        })
                MaterialDesignTextField(viewModel: loader.passwordTextFieldViewModel,
                                        onTextChanged: { text in
                                            
                                        })
                MaterialDesignTextField(viewModel: loader.repeatPasswordTextFieldViewModel,
                                        onTextChanged: { text in
                                            
                                        })
                LoginButton(title: loader.buttonTitle,
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
        var emailTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = EmailTextFieldViewModel()
        var passwordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = RegisterPasswordTextFieldViewModel()
        var repeatPasswordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = RepeatPasswordTextFieldViewModel()
        var buttonTitle = "Next"
        func nextButtonTapped() {}
    }
}
