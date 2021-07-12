//
//  SwiftUILoginViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.4.21..
//

import UIKit
import SwiftUI

public final class SwiftUILoginViewControllerFactory: AuthorizationViewControllerFactory {
    
    private let envFactory: EnvironmentViewModelFactory
    
    init(envFactory: EnvironmentViewModelFactory) {
        self.envFactory = envFactory
    }

    public func makeLoginScreen(service: LoginUserService,
                                environmentStorage: EnvironmentStorage,
                                onSelectEnvironmentTapped: @escaping Observer<EnvironmentViewModel>,
                                onLoginSuccess: @escaping Observer<Void>,
                                onRegisterTapped: @escaping Observer<Void>,
                                onForgotPasswordTapped: @escaping Observer<Void>,
                                onLoading: @escaping Observer<Bool>) -> UIViewController {
        let environmentViewModel = envFactory.createEnvironment(type: .serbia)
        let loginScreenViewModel = LoginScreenViewModel(logoImage: "biologer_logo_icon",
                                                        labelsViewModel: LoginLabelsViewModel(),
                                                        environmentViewModel: environmentViewModel,
                                                        userNameTextFieldViewModel: UserNameTextFieldViewModel(),
                                                        passwordTextFieldViewModel: PasswordTextFieldViewModel(),
                                                        service: service,
                                                        environmentStorage: environmentStorage,
                                                        onSelectEnvironmentTapped: onSelectEnvironmentTapped,
                                                        onLoginSuccess: onLoginSuccess,
                                                        onRegisterTapped: onRegisterTapped,
                                                        onForgotPasswordTapped: onForgotPasswordTapped,
                                                        onLoading: onLoading)
        let loginScreen = LoginScreen(viewModel: loginScreenViewModel)
        return UIHostingController(rootView: loginScreen)
    }
    
    public func makeEnvironmentScreen(selectedViewModel: EnvironmentViewModel,
                                      delegate: EnvironmentScreenViewModelProtocol?,
                                      onSelectedEnvironment: @escaping Observer<Void>) -> UIViewController {
        
        let envViewModel = [envFactory.createEnvironment(type: .serbia),
                            envFactory.createEnvironment(type: .croatia),
                            envFactory.createEnvironment(type: .bosniaAndHerzegovina),
                            envFactory.createEnvironment(type: .develop)]
        
        let viewModel = EnvironmentScreenViewModel(environmentsViewModel: envViewModel,
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
