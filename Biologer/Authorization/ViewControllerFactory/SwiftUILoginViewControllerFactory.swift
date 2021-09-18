//
//  SwiftUILoginViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.4.21..
//

import UIKit
import SwiftUI

public final class SwiftUILoginViewControllerFactory: AuthorizationViewControllerFactory {

    public func makeLoginScreen(service: LoginUserService,
                                environmentViewModel: EnvironmentViewModel,
                                onSelectEnvironmentTapped: @escaping Observer<EnvironmentViewModel>,
                                onLoginSuccess: @escaping Observer<Token>,
                                onLoginError: @escaping Observer<APIError>,
                                onRegisterTapped: @escaping Observer<Void>,
                                onForgotPasswordTapped: @escaping Observer<Void>,
                                onLoading: @escaping Observer<Bool>) -> UIViewController {
        let loginScreenViewModel = LoginScreenViewModel(logoImage: "biologer_logo_icon",
                                                        labelsViewModel: LoginLabelsViewModel(),
                                                        environmentViewModel: environmentViewModel,
                                                        userNameTextFieldViewModel: UserNameTextFieldViewModel(),
                                                        passwordTextFieldViewModel: PasswordTextFieldViewModel(),
                                                        service: service,
                                                        onSelectEnvironmentTapped: onSelectEnvironmentTapped,
                                                        onLoginSuccess: onLoginSuccess,
                                                        onLoginError: onLoginError,
                                                        onRegisterTapped: onRegisterTapped,
                                                        onForgotPasswordTapped: onForgotPasswordTapped,
                                                        onLoading: onLoading)
        let loginScreen = LoginScreen(viewModel: loginScreenViewModel)
        return UIHostingController(rootView: loginScreen)
    }
    
    public func makeEnvironmentScreen(selectedViewModel: EnvironmentViewModel,
                                      envViewModels: [EnvironmentViewModel],
                                      delegate: EnvironmentScreenViewModelProtocol?,
                                      onSelectedEnvironment: @escaping Observer<EnvironmentViewModel>) -> UIViewController {
        
        let viewModel = EnvironmentScreenViewModel(environmentsViewModel: envViewModels,
                                                   selectedViewModel: selectedViewModel,
                                                   delegate: delegate,
                                                   onSelectedEnvironment: onSelectedEnvironment)
        
        let envScreen = EnvironmentScreen(loader: viewModel)
        let viewController = UIHostingController(rootView: envScreen)
        
        return viewController
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
                                            topImage: String,
                                            service: RegisterUserService,
                                            dataLicense: CheckMarkItem,
                                            imageLicense: CheckMarkItem,
                                            onReadPrivacyPolicy: @escaping Observer<Void>,
                                            onDataLicense: @escaping Observer<CheckMarkItem>,
                                            onImageLicense: @escaping Observer<CheckMarkItem>,
                                            onSuccess: @escaping Observer<Token>,
                                            onError: @escaping Observer<APIError>,
                                            onLoading: @escaping Observer<Bool>) -> UIViewController {
        
        let viewModel = RegisterStepThreeScreenViewModel(user: user,
                                                         topImage: topImage,
                                                         service: service,
                                                         dataLicense: dataLicense,
                                                         imageLicense: imageLicense,
                                                         onReadPrivacyPolicy: onReadPrivacyPolicy,
                                                         onDataLicense: onDataLicense,
                                                         onImageLicense: onImageLicense,
                                                         onSuccess: onSuccess,
                                                         onError: onError,
                                                         onLoading: onLoading)
        let screen = RegisterStepThreeScreen(loader: viewModel)
        let viewController = UIHostingController(rootView: screen)
        return viewController
    }
    
    public func makeSplashScreen(onSplashScreenDone: @escaping Observer<Void>) -> UIViewController {
        let viewModel = SplashScreenViewModel(onSplashScreenDone: onSplashScreenDone)
        let screen = SplashScreen(viewModel: viewModel)
        let controller = UIHostingController(rootView: screen)
        return controller
    }
}
