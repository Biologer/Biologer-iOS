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
                                onSelectEnvironmentTapped: @escaping Observer<EnvironmentViewModelProtocol>,
                                   onLoginTapped: @escaping Observer<Void>,
                                   onRegisterTapped: @escaping Observer<Void>,
                                   onForgotPasswordTapped: @escaping Observer<Void>) -> UIViewController {
        let environmentViewModel = EnvironmentViewModel(title: "Srbija", image: "hammer_icon", url: "www.apple.com", isSelected: true)
        let loginScreenViewModel = LoginScreenViewModel(logoImage: "biologer_logo_icon",
                                                        labelsViewModel: LoginLabelsViewModel(),
                                                        environmentViewModel: environmentViewModel,
                                                        userNameTextFieldViewModel: UserNameTextFieldViewModel(),
                                                        passwordTextFieldViewModel: PasswordTextFieldViewModel(),
                                                        service: service,
                                                        onSelectEnvironmentTapped: onSelectEnvironmentTapped,
                                                        onLoginTapped: onLoginTapped,
                                                        onRegisterTapped: onRegisterTapped,
                                                        onForgotPasswordTapped: onForgotPasswordTapped)
        let loginScreen = LoginScreen(viewModel: loginScreenViewModel)
        return UIHostingController(rootView: loginScreen)
    }
    
    public func makeEnvironmentScreen(selectedViewModel: EnvironmentViewModel,
                                      delegate: EnvironmentScreenViewModelProtocol?,
                                      onSelectedEnvironment: @escaping Observer<Void>) -> UIViewController {
        
        let viewModel = EnvironmentScreenViewModel(selectedViewModel: selectedViewModel,
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
                                            service: RegisterUserService,
                                            dataLicense: DataLicense,
                                            imageLicense: DataLicense,
                                            onReadPrivacyPolicy: @escaping Observer<Void>,
                                            onDataLicense: @escaping Observer<DataLicense>,
                                            onImageLicense: @escaping Observer<DataLicense>,
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
    
    public func makeLicenseScreen(dataLicenses: [DataLicense],
                                  delegate: DataLicenseScreenDelegate?,
                                  onLicenseTapped: @escaping Observer<Void>) -> UIViewController {
        
        let viewModel = DataLicenseScreenViewModel(dataLicenses: dataLicenses,
                                                   delegate: delegate,
                                                   onLicenseTapped: onLicenseTapped)
        
        let screen = DataLicenseScreen(loader: viewModel)
        let viewController = UIHostingController(rootView: screen)
        return viewController
    }
}
