//
//  LoginScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import SwiftUI

public protocol LoginScreenLoader: ObservableObject {
    var logoImage: String { get }
    var environmentPlaceholder: String { get }
    var environmentViewModel: EnvironmentViewModel { get }
    var labelsViewModel: LoginLabelsViewModel { get set }
    var userNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol { get set }
    var passwordTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol { get set }
    func selectEnvironment()
    func login()
    func register()
    func forgotPassword()
}

struct LoginScreen<ViewModel>: View where ViewModel: LoginScreenLoader {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Image(viewModel.logoImage)
                    .resizable()
                    .frame(height: 130)
                    .padding(.bottom, 30)
                MaterialDesignTextField(viewModel: viewModel.userNameTextFieldViewModel,
                                        onTextChanged: { text in
                                            viewModel.userNameTextFieldViewModel.text = text
                                            viewModel.userNameTextFieldViewModel.type = .success
                                        },
                                        textAligment: .left)
                    .padding(.bottom, 20)
                MaterialDesignTextField(viewModel: viewModel.passwordTextFieldViewModel,
                                        onTextChanged: { text in
                                            viewModel.passwordTextFieldViewModel.text = text
                                            viewModel.passwordTextFieldViewModel.type = .success
                                        },
                                        onIconTapped: { _ in
                                            viewModel.toggleIsCodeEntryPassword()
                                        },
                                        textAligment: .left)
                    .padding(.bottom, 20)
                
                LoginEnvView(environmentPlacehoder: viewModel.environmentPlaceholder,
                             viewModel: viewModel.environmentViewModel,
                             onEnvTapped: { env in
                                viewModel.selectEnvironment()
                             })
                    .padding(.bottom, 20)
                
                BiologerButton(title: viewModel.labelsViewModel.loginButtonTitle,
                            onTapped: { _ in
                                viewModel.login()
                            })
                    .padding(.bottom, 30)
                HStack(spacing: 10) {
                    Text(viewModel.labelsViewModel.dontHaveAccountTitle)
                        .font(.titleFont)
                        .foregroundColor(.gray)
                    Button(action: {
                        viewModel.register()
                    }, label: {
                        Text(viewModel.labelsViewModel.registerButtonTitle)
                            .font(.titleFontBold)
                            .foregroundColor(Color.biologerGreenColor)
                    })
                }
                .padding(.bottom, 20)
                Button(action: {
                    viewModel.forgotPassword()
                }, label: {
                    Text(viewModel.labelsViewModel.forgotPasswordTitle)
                        .foregroundColor(Color.biologerGreenColor)
                        .font(.titleFontBold)
                })
            }
            .navigationBarBackButtonHidden(true)
            .padding(.bottom, 30)
            .padding(.leading, 30)
            .padding(.trailing, 30)
        }
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen(viewModel: StubLoginScreenViewModel())
    }
    
    private class StubLoginScreenViewModel: LoginScreenLoader {
        var environmentPlaceholder: String = "Select Environment"
        var logoImage: String = "biologer_logo_icon"
        var environmentViewModel: EnvironmentViewModel = EnvironmentViewModel(id: 1,
                                                                              title: "Serbia",
                                                                              image: "serbia_flag",
                                                                              env: Environment(host: serbiaHost,
                                                                                               path: serbiaPath,
                                                                                               clientSecret: serbiaClientSecret,
                                                                                               cliendId: cliendIdSer),
                                                                              isSelected: false)
        var labelsViewModel: LoginLabelsViewModel = LoginLabelsViewModel()
        var userNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = UserNameTextFieldViewModel()
        var passwordTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = PasswordTextFieldViewModel()
        
        func selectEnvironment() {}
        func login() {}
        func register() {}
        func forgotPassword() {}
    }
}