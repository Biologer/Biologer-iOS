//
//  LoginScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import SwiftUI

public enum MaterialDesignTextFieldType {
    case empty
    case success
    case failure
}

public enum MaterialDesignTextFieldTralingViewType {
    case password
    case none
    case other
}

public protocol MaterialDesignTextFieldViewMoodelProtocol {
    var text: String { get set }
    var placeholder: String { get }
    var errorText: String { get set }
    var isCodeEntry: Bool { get set }
    var tralingImage: String? { get }
    var tralingErrorImage: String? { get }
    var isUserInteractionEnabled: Bool { get }
    var type: MaterialDesignTextFieldType { get set }
}

public protocol EnvironmentViewModelProtocol {
    var title: String { get }
    var image: String { get }
    var url: String { get }
}

extension MaterialDesignTextFieldViewMoodelProtocol {
    func getErrorText() -> String {
        return type == .failure ? errorText : ""
    }
    
    func getIconImageByType() -> UIImageView? {
        if type == .failure, let errorImage = tralingErrorImage {
            return UIImageView(image: UIImage(named: errorImage)!)
        } else if let image = tralingImage {
            return UIImageView(image: UIImage(named: image)!)
        } else {
            return nil
        }
    }
}

public protocol LoginScreenLoader: ObservableObject {
    var logoImage: String { get }
    var environmentViewModel: EnvironmentViewModelProtocol { get }
    var labelsViewModel: LoginLabelsViewModel { get set }
    var userNameTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol { get set }
    var passwordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol { get set }
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
                EnvironmentLoginView(environmentViewModel: viewModel.environmentViewModel, envImage: "env_icon")
                    .padding(.bottom, 20)
                MaterialDesignTextField(viewModel: viewModel.userNameTextFieldViewModel,
                                        onTextChanged: { text in
                                            viewModel.userNameTextFieldViewModel.text = text
                                            viewModel.userNameTextFieldViewModel.type = .success
                                        })
                    .padding(.bottom, 20)
                MaterialDesignTextField(viewModel: viewModel.passwordTextFieldViewModel,
                                        onTextChanged: { text in
                                            viewModel.passwordTextFieldViewModel.text = text
                                            viewModel.passwordTextFieldViewModel.type = .success
                                        })
                    .padding(.bottom, 20)
                
                LoginButton(title: viewModel.labelsViewModel.loginButtonTitle,
                            onTapped: { _ in
                                viewModel.login()
                            })
                    .padding(.bottom, 30)
                HStack(spacing: 20) {
                    Text(viewModel.labelsViewModel.dontHaveAccountTitle)
                        .foregroundColor(.gray)
                    Button(action: {
                        viewModel.register()
                    }, label: {
                        Text(viewModel.labelsViewModel.registerButtonTitle)
                            .foregroundColor(Color.biologerGreenColor)
                            .bold()
                    })
                }
                .padding(.bottom, 20)
                Button(action: {
                    viewModel.forgotPassword()
                }, label: {
                    Text(viewModel.labelsViewModel.forgotPasswordTitle)
                        .foregroundColor(Color.biologerGreenColor)
                        .bold()
                })
            }
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
        var environmentViewModel: EnvironmentViewModelProtocol = EnvironmentViewModel(title: "Srbija", image: "serbia_flag", url: "www.apple.com")
        var labelsViewModel: LoginLabelsViewModel = LoginLabelsViewModel()
        var userNameTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = UserNameTextFieldViewModel()
        var passwordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = PasswordTextFieldViewModel()
        
        func selectEnvironment() {}
        func login() {}
        func register() {}
        func forgotPassword() {}
    }
}