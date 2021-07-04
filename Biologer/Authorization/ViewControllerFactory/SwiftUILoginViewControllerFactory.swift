//
//  SwiftUILoginViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.4.21..
//

import UIKit
import SwiftUI

public final class SwiftUILoginViewControllerFactory: AuthorizationViewControllerFactory {
    public func makeLoginScreen(onSelectEnvironmentTapped: @escaping Observer<Void>,
                                   onLoginTapped: @escaping Observer<Void>,
                                   onRegisterTapped: @escaping Observer<Void>,
                                   onForgotPasswordTapped: @escaping Observer<Void>) -> UIViewController {
        let environmentViewModel = EnvironmentViewModel(title: "Srbija", image: "hammer_icon", url: "www.apple.com")
        let loginScreenViewModel = LoginScreenViewModel(logoImage: "biologer_logo_icon",
                                                        labelsViewModel: LoginLabelsViewModel(),
                                                        environmentViewModel: environmentViewModel,
                                                        userNameTextFieldViewModel: UserNameTextFieldViewModel(),
                                                        passwordTextFieldViewModel: PasswordTextFieldViewModel(),
                                                        onSelectEnvironmentTapped: { _ in },
                                                        onLoginTapped: onLoginTapped,
                                                        onRegisterTapped: { _ in },
                                                        onForgotPasswordTapped: { _ in })
        let loginScreen = LoginScreen(viewModel: loginScreenViewModel)
        return UIHostingController(rootView: loginScreen)
    }
    
    public func makeRegisterFirstStepScreen(user: User,
                                            onNextTapped: @escaping Observer<User>) -> UIViewController {
        let viewModel = RegisterStepOneScreenViewModel(user: User(),
                                                       onNextTapped: onNextTapped)
        let screen = RegisterStepOneScreen(loader: viewModel)
        let viewController = UIHostingController(rootView: screen)
        return viewController
    }
    
    public func makeRegisterSecondStepScreen(user: User,
                                             onNextTapped: @escaping Observer<User>) -> UIViewController {
        let viewModel = RegisterStepTwoScreenViewModel(user: user,
                                                       onNextTapped: onNextTapped)
        let screen = RegisterStepTwoScreen(loader: viewModel)
        let viewController = UIHostingController(rootView: screen)
        return viewController
    }
    
    public func makeRegisterThreeStepScreen(user: User,
                                            service: AuthorizationService,
                                            dataLicense: DataLicense,
                                            imageLicense: DataLicense,
                                            onReadPrivacyPolicy: @escaping Observer<Void>,
                                            onDataLicense: @escaping Observer<Void>,
                                            onImageLicense: @escaping Observer<Void>,
                                            onSuccess: @escaping Observer<Void>,
                                            onError: @escaping Observer<Void>) -> UIViewController {
        
        let viewModel = RegisterStepThreeScreenViewModel(user: user,
                                                         service: service,
                                                         dataLicense: dataLicense,
                                                         imageLicense: imageLicense,
                                                         onReadPrivacyPolicy: onReadPrivacyPolicy,
                                                         onDataLicense: onDataLicense,
                                                         onImageLicense: onImageLicense,
                                                         onSuccess: onSuccess,
                                                         onError: onError)
        let screen = RegisterStepThreeScreen(loader: viewModel)
        let viewController = UIHostingController(rootView: screen)
        return viewController
    }
}
