//
//  SwiftUILoginViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.4.21..
//

import UIKit
import SwiftUI

public final class SwiftUILoginViewControllerFactory: LoginViewControllerFactory {
    public func presentLoginScreen(onSelectEnvironmentTapped: @escaping Observer<Void>,
                                   onLoginTapped: @escaping Observer<Void>,
                                   onRegisterTapped: @escaping Observer<Void>,
                                   onForgotPasswordTapped: @escaping Observer<Void>
    ) -> UIViewController {
        let environmentViewModel = EnvironmentViewModel(title: "Srbija", image: "hammer_icon", url: "www.apple.com")
        let loginScreenViewModel = LoginScreenViewModel(logoImage: "biologer_logo_icon",
                                                        labelsViewModel: LoginLabelsViewModel(),
                                                        environmentViewModel: environmentViewModel,
                                                        userNameTextFieldViewModel: UserNameTextFieldViewModel(),
                                                        passwordTextFieldViewModel: PasswordTextFieldViewModel(),
                                                        onSelectEnvironmentTapped: { _ in },
                                                        onLoginTapped: { _ in },
                                                        onRegisterTapped: { _ in },
                                                        onForgotPasswordTapped: { _ in })
        let loginScreen = LoginScreen(viewModel: loginScreenViewModel)
        return UIHostingController(rootView: loginScreen)
    }
}
