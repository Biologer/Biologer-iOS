//
//  LoginViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.4.21..
//

import UIKit

public protocol AuthorizationViewControllerFactory {
    func makeLoginScreen(service: LoginUserService,
                         onSelectEnvironmentTapped: @escaping Observer<Void>,
                                   onLoginTapped: @escaping Observer<Void>,
                                   onRegisterTapped: @escaping Observer<Void>,
                                   onForgotPasswordTapped: @escaping Observer<Void>) -> UIViewController
    func makeRegisterFirstStepScreen(user: User,
                                     onNextTapped: @escaping Observer<User>) -> UIViewController
    func makeRegisterSecondStepScreen(user: User,
                                      onNextTapped: @escaping Observer<User>) -> UIViewController
    func makeRegisterThreeStepScreen(user: User,
                                     service: RegisterUserService,
                                     dataLicense: DataLicense,
                                     imageLicense: DataLicense,
                                     onReadPrivacyPolicy: @escaping Observer<Void>,
                                     onDataLicense: @escaping Observer<Void>,
                                     onImageLicense: @escaping Observer<Void>,
                                     onSuccess: @escaping Observer<Void>,
                                     onError: @escaping Observer<Void>) -> UIViewController
}
