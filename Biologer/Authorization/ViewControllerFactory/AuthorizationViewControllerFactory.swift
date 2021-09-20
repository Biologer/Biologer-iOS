//
//  LoginViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.4.21..
//

import UIKit

public protocol AuthorizationViewControllerFactory {
    func makeLoginScreen(service: LoginUserService,
                         environmentViewModel: EnvironmentViewModel,
                         onSelectEnvironmentTapped: @escaping Observer<EnvironmentViewModel>,
                         onLoginSuccess: @escaping Observer<Token>,
                         onLoginError: @escaping Observer<APIError>,
                         onRegisterTapped: @escaping Observer<Void>,
                         onForgotPasswordTapped: @escaping Observer<Void>,
                         onLoading: @escaping Observer<Bool>) -> UIViewController
    func makeEnvironmentScreen(selectedViewModel: EnvironmentViewModel,
                               envViewModels: [EnvironmentViewModel],
                               delegate: EnvironmentScreenViewModelProtocol?,
                               onSelectedEnvironment: @escaping Observer<EnvironmentViewModel>) -> UIViewController
    func makeRegisterFirstStepScreen(user: RegisterUser,
                                     onNextTapped: @escaping Observer<RegisterUser>) -> UIViewController
    func makeRegisterSecondStepScreen(user: RegisterUser,
                                      onNextTapped: @escaping Observer<RegisterUser>) -> UIViewController
    func makeRegisterThreeStepScreen(user: RegisterUser,
                                     topImage: String,
                                     service: RegisterUserService,
                                     dataLicense: CheckMarkItem,
                                     imageLicense: CheckMarkItem,
                                     onReadPrivacyPolicy: @escaping Observer<Void>,
                                     onDataLicense: @escaping Observer<CheckMarkItem>,
                                     onImageLicense: @escaping Observer<CheckMarkItem>,
                                     onSuccess: @escaping Observer<Token>,
                                     onError: @escaping Observer<APIError>,
                                     onLoading: @escaping Observer<Bool>) -> UIViewController
    func makeSplashScreen(onSplashScreenDone: @escaping Observer<Void>) -> UIViewController
}
