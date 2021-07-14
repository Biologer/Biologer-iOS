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
                                onLoginSuccess: @escaping Observer<Void>,
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
                                            dataLicense: DataLicense,
                                            imageLicense: DataLicense,
                                            onReadPrivacyPolicy: @escaping Observer<Void>,
                                            onDataLicense: @escaping Observer<DataLicense>,
                                            onImageLicense: @escaping Observer<DataLicense>,
                                            onSuccess: @escaping Observer<Void>,
                                            onError: @escaping Observer<Void>,
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
    
    public func makeLicenseScreen(dataLicenses: [DataLicense],
                                  selectedDataLicense: DataLicense,
                                  delegate: DataLicenseScreenDelegate?,
                                  onLicenseTapped: @escaping Observer<Void>) -> UIViewController {
        
        let viewModel = DataLicenseScreenViewModel(dataLicenses: dataLicenses,
                                                   selectedDataLicense: selectedDataLicense,
                                                   delegate: delegate,
                                                   onLicenseTapped: onLicenseTapped)
        
        let screen = DataLicenseScreen(loader: viewModel)
        let viewController = UIHostingController(rootView: screen)
        return viewController
    }
}
