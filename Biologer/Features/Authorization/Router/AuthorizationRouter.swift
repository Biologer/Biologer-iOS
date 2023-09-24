//
//  AuthorizationRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 26.6.21..
//

import UIKit
import SwiftUI

public final class AuthorizationRouter {
    private let factory: AuthorizationViewControllerFactory
    private let navigationController: UINavigationController
    private let commonViewControllerFactory: CommonViewControllerFactory
    private let swiftUIAlertViewControllerFactory: AlertViewControllerFactory
    private let environmentStorage: EnvironmentStorage
    private let tokenStorage: TokenStorage
    private let taxonLoader: TaxonLoader
    
    private var selectedEnvironmentImage: String = ""
    
    public var onLoginSuccess: Observer<Void>?
    
    private lazy var onLoading: Observer<Bool> = { [weak self] isLoading in
        guard let self = self else { return }
        if isLoading {
            let loader  = self.commonViewControllerFactory.createBlockingProgress()
            self.navigationController.present(loader, animated: false, completion: nil)
        } else {
            self.navigationController.dismiss(animated: false, completion: nil)
        }
    }
    
    init(factory: AuthorizationViewControllerFactory,
         commonViewControllerFactory: CommonViewControllerFactory,
         swiftUIAlertViewControllerFactory: AlertViewControllerFactory,
         navigationController: UINavigationController,
         environmentStorage: EnvironmentStorage,
         tokenStorage: TokenStorage,
         taxonLoader: TaxonLoader) {
        self.factory = factory
        self.commonViewControllerFactory = commonViewControllerFactory
        self.swiftUIAlertViewControllerFactory = swiftUIAlertViewControllerFactory
        self.navigationController = navigationController
        self.environmentStorage = environmentStorage
        self.tokenStorage = tokenStorage
        self.taxonLoader = taxonLoader
    }
    
    // MARK: - Public Functions
    
    public func start(shouldPresentIntroScreens: Bool) {
        if shouldPresentIntroScreens {
            showHelpScreen()
        } else {
            showLoginScreen()
        }
    }

    // MARK: - Private Functions
    
    private func showLoginScreen() {
        
        var envDelegate: EnvironmentScreenViewModelProtocol?
        
        let defaultEnv = EnvironmentViewModelFactory.createEnvironment(type: .serbia)
        environmentStorage.saveEnvironment(env: defaultEnv.env)
        selectedEnvironmentImage = defaultEnv.image
        
        let loginViewController = factory.makeLoginScreen(environmentViewModel: defaultEnv,
                                                          onSelectEnvironmentTapped: { [weak self] env in
            self?.showEnvironmentScreen(selectedViewModel: env,
                                        delegate: envDelegate)
        },
                                                          onLoginSuccess: { [weak self] token in
            self?.taxonLoader.getTaxons(completion: { [weak self] error in
                if let error = error {
                    print("Error from saveing CSV file: \(error.localizedDescription)")
                } else {
                    self?.tokenStorage.saveToken(token: token)
                    self?.onLoading((false))
                    self?.onLoginSuccess?(())
                }
            })
        },
                                                          onLoginError: { error in
            self.showErrorAlert(popUpType: .error,
                                title: error.title,
                                description: error.description)
        },
                                                          onRegisterTapped: { [weak self] _ in
            self?.showRegisterStepOneScreen()
        },
                                                          onForgotPasswordTapped: { [weak self] _ in
            self?.showSafari(path: "/password/reset")
        },
                                                          onLoading: onLoading)
        
        let viewController = loginViewController as? UIHostingController<LoginScreen<LoginScreenViewModel>>
        envDelegate = viewController?.rootView.viewModel
        
        loginViewController.navigationItem.hidesBackButton = true
        navigationController.pushViewController(loginViewController, animated: true)
    }
    
    private func showEnvironmentScreen(selectedViewModel: EnvironmentViewModel,
                                       delegate: EnvironmentScreenViewModelProtocol? = nil) {
        
        let envs = EnvironmentViewModelFactory.createAllEnvironments()
        let enviViewController = factory.makeEnvironmentScreen(selectedViewModel: selectedViewModel,
                                                               envViewModels: envs,
                                                               delegate: delegate,
                                                               onSelectedEnvironment: { [weak self] env in
                                                                    self?.environmentStorage.saveEnvironment(env: env.env)
                                                                    self?.selectedEnvironmentImage = env.image
                                                                    self?.navigationController.setNavigationBarTransparent(true)
                                                                    self?.navigationController.popViewController(animated: true)
                                                       })
        
        enviViewController.setBiologerBackBarButtonItem { [weak self] in
            self?.navigationController.setNavigationBarTransparent(true)
            self?.goBack()
        }
        enviViewController.setBiologerTitle(text: "Env.nav.title".localized)
        self.navigationController.setNavigationBarTransparent(false)
        self.navigationController.pushViewController(enviViewController, animated: true)
    }
    
    private func showRegisterStepOneScreen() {
        let stepOneViewController = factory.makeRegisterFirstStepScreen(user: RegisterUser(),
                                                                        onNextTapped: { [weak self] user in
                                                                            self?.showRegisterStepTwoScreen(user: user)
                                                                        })
        stepOneViewController.setBiologerBackBarButtonItem { [weak self] in
            self?.navigationController.setNavigationBarTransparent(true)
            self?.goBack()
        }
        stepOneViewController.setBiologerTitle(text: "Register.one.nav.title".localized)
        self.navigationController.setNavigationBarTransparent(false)
        self.navigationController.pushViewController(stepOneViewController, animated: true)
    }
    
    private func showRegisterStepTwoScreen(user: RegisterUser) {
        let stepTwoViewController = factory.makeRegisterSecondStepScreen(user: user,
                                                                         onNextTapped: { [weak self] user in
                                                                            self?.showRegisterThirdStepScreen(user: user)
                                                                         })
        stepTwoViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        stepTwoViewController.setBiologerTitle(text: "Register.two.nav.title".localized)
        self.navigationController.pushViewController(stepTwoViewController, animated: true)
    }
    
    private func showRegisterThirdStepScreen(user: RegisterUser) {
        let dataLicenses = CheckMarkItemMapper.getDataLicense()
        let imageLicenses = CheckMarkItemMapper.getImageLicense()
        let dataLicense = dataLicenses[0]
        let imageLicense = imageLicenses[0]
        var dataLicenseDelegate: CheckMarkScreenDelegate?
        
        let stepThirdViewController = factory.makeRegisterThreeStepScreen(user: user,
                                                                          topImage: self.selectedEnvironmentImage,
                                                                          dataLicense: dataLicense,
                                                                          imageLicense: imageLicense,
                                                                          onReadPrivacyPolicy: { [weak self] _ in
            self?.showSafari(path: "/pages/privacy-policy")
        },
                                                                          onDataLicense: { [weak self] dataLicense in
            self?.showLicenseScreen(isDataLicense: true,
                                    selectedItem: dataLicense,
                                    items: dataLicenses,
                                    presentDatePicker: dataLicenseDelegate)
        },
                                                                          onImageLicense: { [weak self] imageLicense in
            self?.showLicenseScreen(isDataLicense: false,
                                    selectedItem: imageLicense,
                                    items: imageLicenses,
                                    presentDatePicker: dataLicenseDelegate)
        },
                                                                          onSuccess: { [weak self] token in
            
            self?.taxonLoader.getTaxons(completion: { [weak self] error in
                if let error = error {
                    print("Error from saveing CSV file: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self?.onLoading((false))
                        print("On Login Sucess called")
                        self?.showConfirmAlert(popUpType: .success,
                                               title: "Register.three.successPopUp.title".localized,
                                               description: "Register.three.successPopUp.description".localized,
                                               onTap: { _ in
                            self?.tokenStorage.saveToken(token: token)
                            self?.navigationController.dismiss(animated: true, completion: nil)
                            self?.onLoginSuccess?(())
                        })
                    }
                }
            })
        },
                                                                          onError: { [weak self] error in
            self?.showErrorAlert(popUpType: .error,
                                 title: error.title,
                                 description: error.description)
        },
                                                                          onLoading: onLoading)
        
        let viewController = stepThirdViewController as? UIHostingController<RegisterStepThreeScreen<RegisterStepThreeScreenViewModel>>
        dataLicenseDelegate = viewController?.rootView.loader
        
        stepThirdViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        stepThirdViewController.setBiologerTitle(text: "Register.three.nav.title".localized)
        self.navigationController.pushViewController(stepThirdViewController, animated: true)
    }
    
    private func showLicenseScreen(isDataLicense: Bool,
                                   selectedItem: CheckMarkItem,
                                   items: [CheckMarkItem],
                                   presentDatePicker: CheckMarkScreenDelegate?) {
        
        let dataLicenseViewController = commonViewControllerFactory.makeLicenseScreen(items: items,
                                                                                             selectedItem: selectedItem,
                                                                  delegate: presentDatePicker) { [weak self] dataLicenses in
            self?.navigationController.popViewController(animated: true)
        }
        dataLicenseViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        dataLicenseViewController.setBiologerTitle(text: isDataLicense ? "DataLicense.nav.title".localized : "ImgLicense.nav.title".localized)
        self.navigationController.pushViewController(dataLicenseViewController, animated: true)
    }
    
    private func showHelpScreen() {
        let vc = commonViewControllerFactory.makeHelpScreen(onDone: { _ in
            UserDefaults.standard.set(true, forKey: UserDefaultsConstants.shouldPresentTutorialKey)
            self.showLoginScreen()
        })
        vc.removeBackButtonItem()
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func showConfirmAlert(popUpType: PopUpType,
                                  title: String,
                                  description: String,
                                  onTap: @escaping Observer<Void>) {
        let vc = swiftUIAlertViewControllerFactory.makeConfirmationAlert(popUpType: popUpType,
                                                                         title: title,
                                                                         description: description,
                                                                         onTapp: onTap)
        self.navigationController.present(vc, animated: true, completion: nil)
    }
    
    private func showErrorAlert(popUpType: PopUpType,
                                title: String,
                                description: String) {
        let vc = swiftUIAlertViewControllerFactory.makeConfirmationAlert(popUpType: popUpType,
                                                                  title: title,
                                                                  description: description,
                                                                  onTapp: { _ in
                                                                    self.navigationController.dismiss(animated: true, completion: nil)
                                                                  })
        self.navigationController.present(vc, animated: true, completion: nil)
    }
    
    private func showSplashScreen() {
        let vc = factory.makeSplashScreen(onSplashScreenDone: {
            self.showLoginScreen()
        })
        self.navigationController.setViewControllers([vc], animated: false)
    }
    
    @objc func goBack() {
        navigationController.popViewController(animated: true)
    }
    
    private func showSafari(path: String) {
        if let env = environmentStorage.getEnvironment() {
            let url = "https://\(env.host)\(env.path)\(path)"
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }
    }
}
