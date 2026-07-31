//
//  LoginScreenV2.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import SwiftUI

struct LoginScreenV2: View {

    private let environmentViewModel: EnvironmentViewModel

    @StateObject
    private var viewModel: LoginScreenV2ViewModel

    init(
        environmentViewModel: EnvironmentViewModel,
        viewModel: LoginScreenV2ViewModel
    ) {
        self.environmentViewModel = environmentViewModel
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    Image("biologer_logo_icon")
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
                        title: "Login.btn.login".localized,
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
            if viewModel.isLoading {
                BiologerProgressView()
            }
        }
        .onAppear {
            viewModel.updateEnvironment(environmentViewModel)
        }
        .onChange(of: environmentViewModel) { environment in
            viewModel.updateEnvironment(environment)
        }
    }
}

struct LoginScreenV2_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreenV2(
            environmentViewModel: EnvironmentViewModelFactory().createEnvironment(type: .croatia),
            viewModel: LoginScreenV2ViewModel(
                environmentViewModel: EnvironmentViewModelFactory().createEnvironment(type: .croatia),
                useCase: StubLoginUseCase(),
                onSelectEnvironmentTapped: { },
                onLoginSuccess: { },
                onRegisterTapped: { },
                onForgotPasswordTapped: { },
                onLoginError: { _ in })
            )
    }

    private class StubLoginUseCase: LoginUserUseCase {
        func login(email: String, username: String, password: String) async throws(LoginError) {
            
        }
    }
}
