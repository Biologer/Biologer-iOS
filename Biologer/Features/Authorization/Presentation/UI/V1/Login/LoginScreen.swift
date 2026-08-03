//
//  LoginScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import SwiftUI

public protocol LoginScreenLoader: ObservableObject {
    var logoImage: String { get }
    var environmentViewModel: EnvironmentViewModel { get }
    var userNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol { get set }
    var passwordTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol { get set }
    func selectEnvironment()
    func login() async
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
                
                MaterialDesignTextField(
                    viewModel: viewModel.userNameTextFieldViewModel,
                    onTextChanged: { text in
                        viewModel.userNameTextFieldViewModel.text = text
                        viewModel.userNameTextFieldViewModel.type = .success
                    },
                    textAligment: .left
                )
                .padding(.bottom, 20)
                
                MaterialDesignTextField(
                    viewModel: viewModel.passwordTextFieldViewModel,
                    onTextChanged: { text in
                        viewModel.passwordTextFieldViewModel.text = text
                        viewModel.passwordTextFieldViewModel.type = .success
                    },
                    onIconTapped: { _ in
                        viewModel.toggleIsCodeEntryPassword()
                    },
                    textAligment: .left
                )
                .padding(.bottom, 20)
                
                LoginEnvView(
                    environmentPlacehoder: "Login.env.placeholder".localized,
                    viewModel: viewModel.environmentViewModel,
                    onEnvTapped: { env in
                        viewModel.selectEnvironment()
                    })
                .padding(.bottom, 20)
                
                BiologerButton(
                    title: "Login.btn.register".localized,
                    onTapped: { _ in
                        Task {
                            await viewModel.login()
                        }
                    })
                    .padding(.bottom, 30)
                
                HStack(spacing: 10) {
                    Text("Login.lb.noAccount".localized)
                        .font(.titleFont)
                        .foregroundColor(.gray)
                    Button(action: {
                        viewModel.register()
                    }, label: {
                        Text("Login.btn.register".localized)
                            .font(.titleFontBold)
                            .foregroundColor(Color.biologerGreenColor)
                    })
                }
                .padding(.bottom, 20)
                Button(action: {
                    viewModel.forgotPassword()
                }, label: {
                    Text("Login.btn.forgotPassword".localized)
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
        var logoImage: String = "biologer_logo_icon"
        var environmentViewModel: EnvironmentViewModel = EnvironmentViewModel(
            id: 1,
            title: "Serbia",
            image: "serbia_flag",
            env: Environment(
                host: APIConstants.serbiaHost,
                path: APIConstants.serbiaLangPath,
                clientSecret: serbiaClientSecret,
                cliendId: cliendIdSer
            ),
            isSelected: false
        )
        var userNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = UserNameTextFieldViewModel()
        var passwordTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = PasswordTextFieldViewModel()
        
        func selectEnvironment() {}
        func login() {}
        func register() {}
        func forgotPassword() {}
    }
}
