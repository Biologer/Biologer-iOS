//
//  LoginViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.4.21..
//

import UIKit

public protocol AuthorizationViewControllerFactory {
    func makeLoginScreen(service: LoginUserService,
                         environmentStorage: EnvironmentStorage,
                         onSelectEnvironmentTapped: @escaping Observer<EnvironmentViewModel>,
                         onLoginSuccess: @escaping Observer<Void>,
                         onRegisterTapped: @escaping Observer<Void>,
                         onForgotPasswordTapped: @escaping Observer<Void>,
                         onLoading: @escaping Observer<Bool>) -> UIViewController
    func makeEnvironmentScreen(selectedViewModel: EnvironmentViewModel,
                               delegate: EnvironmentScreenViewModelProtocol?,
                               onSelectedEnvironment: @escaping Observer<Void>) -> UIViewController
    func makeRegisterFirstStepScreen(user: User,
                                     onNextTapped: @escaping Observer<User>) -> UIViewController
    func makeRegisterSecondStepScreen(user: User,
                                      onNextTapped: @escaping Observer<User>) -> UIViewController
    func makeRegisterThreeStepScreen(user: User,
                                     service: RegisterUserService,
                                     dataLicense: DataLicense,
                                     imageLicense: DataLicense,
                                     onReadPrivacyPolicy: @escaping Observer<Void>,
                                     onDataLicense: @escaping Observer<DataLicense>,
                                     onImageLicense: @escaping Observer<DataLicense>,
                                     onSuccess: @escaping Observer<Void>,
                                     onError: @escaping Observer<Void>,
                                     onLoading: @escaping Observer<Bool>) -> UIViewController
    func makeLicenseScreen(dataLicenses: [DataLicense],
                           selectedDataLicense: DataLicense,
                           delegate: DataLicenseScreenDelegate?,
                           onLicenseTapped: @escaping Observer<Void>) -> UIViewController
}
