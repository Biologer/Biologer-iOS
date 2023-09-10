//
//  SwiftUILoginViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.4.21..
//

import UIKit
import SwiftUI

public final class SwiftUILoginViewControllerFactory: AuthorizationViewControllerFactory {
    
    private let loginService: LoginUserService
    private let registerService: RegisterUserService
    private let dataLicenseStorage: LicenseStorage
    private let imageLicenseStorage: LicenseStorage
    private let emailValidator: StringValidator
    private let passwordValidator: StringValidator
    
    init(loginService: LoginUserService,
         registerService: RegisterUserService,
         dataLicenseStorage: LicenseStorage,
         imageLicenseStorage: LicenseStorage,
         emailValidator: StringValidator,
         passwordValidator: StringValidator) {
        self.loginService = loginService
        self.registerService = registerService
        self.dataLicenseStorage = dataLicenseStorage
        self.imageLicenseStorage = imageLicenseStorage
        self.emailValidator = emailValidator
        self.passwordValidator = passwordValidator
    }

    public func makeLoginScreen(environmentViewModel: EnvironmentViewModel,
                                onSelectEnvironmentTapped: @escaping Observer<EnvironmentViewModel>,
                                onLoginSuccess: @escaping Observer<Token>,
                                onLoginError: @escaping Observer<APIError>,
                                onRegisterTapped: @escaping Observer<Void>,
                                onForgotPasswordTapped: @escaping Observer<Void>,
                                onLoading: @escaping Observer<Bool>) -> UIViewController {
        let loginScreenViewModel = LoginScreenViewModel(environmentViewModel: environmentViewModel,
                                                        service: loginService,
                                                        emailValidator: emailValidator,
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
    
    public func makeRegisterFirstStepScreen(user: RegisterUser,
                                            onNextTapped: @escaping Observer<RegisterUser>) -> UIViewController {
        let viewModel = RegisterStepOneScreenViewModel(user: user,
                                                       onNextTapped: onNextTapped)
        let screen = RegisterStepOneScreen(loader: viewModel)
        let viewController = UIHostingController(rootView: screen)
        return viewController
    }
    
    public func makeRegisterSecondStepScreen(user: RegisterUser,
                                             onNextTapped: @escaping Observer<RegisterUser>) -> UIViewController {
        let viewModel = RegisterStepTwoScreenViewModel(user: user,
                                                       emailValidator: emailValidator,
                                                       passwordValidator: passwordValidator,
                                                       onNextTapped: onNextTapped)
        let screen = RegisterStepTwoScreen(loader: viewModel)
        let viewController = UIHostingController(rootView: screen)
        return viewController
    }
    
    public func makeRegisterThreeStepScreen(user: RegisterUser,
                                            topImage: String,
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
                                                         service: registerService,
                                                         dataLicense: dataLicense,
                                                         imageLicense: imageLicense,
                                                         dataLicenseStorage: dataLicenseStorage,
                                                         imageLicenseStorage: imageLicenseStorage,
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
