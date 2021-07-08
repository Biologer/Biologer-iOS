//
//  AuthorizationRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 26.6.21..
//

import UIKit
import SwiftUI

public final class AuthorizationRouter: NavigationRouter {
    private let factory: AuthorizationViewControllerFactory
    private let navigationController: UINavigationController
    private let loginService: LoginUserService
    private let registerService: RegisterUserService
    private let forgotPasswordService: ForgotPasswordService
    public var onLoginTapped: Observer<Void>?
    
    init(factory: AuthorizationViewControllerFactory,
         navigationController: UINavigationController,
         loginService: LoginUserService,
         registerService: RegisterUserService,
         forgotPasswordService: ForgotPasswordService) {
        self.factory = factory
        self.navigationController = navigationController
        self.loginService = loginService
        self.registerService = registerService
        self.forgotPasswordService = forgotPasswordService
    }
    
    public func start() {
        showLoginScreen()
    }
    
    private func showLoginScreen() {
        let loginViewController = factory.makeLoginScreen(service: loginService,
                                                             onSelectEnvironmentTapped: { _ in },
                                                             onLoginTapped: { [weak self]  _ in
                                                                self?.onLoginTapped?(())
                                                             },
                                                             onRegisterTapped: { [weak self] _ in                                                                self?.showRegisterStepOneScreen()
                                                             },
                                                             onForgotPasswordTapped: { _ in })
        self.navigationController.setViewControllers([loginViewController], animated: false)
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    private func showRegisterStepOneScreen() {
        let stepOneViewController = factory.makeRegisterFirstStepScreen(user: User(),
                                                                        onNextTapped: { [weak self] user in
                                                                            self?.showRegisterStepTwoScreen(user: user)
                                                                        })
        stepOneViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        stepOneViewController.setBiologerTitle(text: "REGISTER STEP ONE")
        self.navigationController.pushViewController(stepOneViewController, animated: true)
    }
    
    private func showRegisterStepTwoScreen(user: User) {
        let stepTwoViewController = factory.makeRegisterSecondStepScreen(user: user,
                                                                         onNextTapped: { [weak self] user in
                                                                            self?.showRegisterThirdStepScreen(user: user)
                                                                         })
        stepTwoViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        stepTwoViewController.setBiologerTitle(text: "REGISTER STEP TWO")
        self.navigationController.pushViewController(stepTwoViewController, animated: true)
    }
    
    private func showRegisterThirdStepScreen(user: User) {
        
        let dataLicenses = [DataLicense(id: 10,
                                        title: "Free (CC BY-SA)",
                                        placeholder: "Data License",
                                        licenseType: .data),
                            DataLicense(id: 20,
                                        title: "Free, NonCommercial (CC BY-SA-NC)",
                                        placeholder: "Data License",
                                        licenseType: .data),
                            DataLicense(id: 30,
                                        title: "Partially Open (restricted to 10km)",
                                        placeholder: "Data License",
                                        licenseType: .data),
                            DataLicense(id: 11,
                                        title: "Temporary closed (publish as free after 3 years)",
                                        placeholder: "Data License",
                                        licenseType: .data),
                            DataLicense(id: 40,
                                        title: "Closed (available to you and the editors)",
                                        placeholder: "Data License",
                                        licenseType: .data)]
        
        let imageLicenses = [DataLicense(id: 10,
                                        title: "Share images for free (CC-BY-SA)",
                                        placeholder: "Image License",
                                        licenseType: .image),
                            DataLicense(id: 20,
                                        title: "Share images as noncommercial (CC-BY-SA-NC)",
                                        placeholder: "Image License",
                                        licenseType: .image),
                            DataLicense(id: 30,
                                        title: "Keep authorship and share online with watermark",
                                        placeholder: "Image License",
                                        licenseType: .image),
                            DataLicense(id: 40,
                                        title: "Keep authorship and restrict images from public domain",
                                        placeholder: "Image License",
                                        licenseType: .image)]
        
        let dataLicense = dataLicenses[0]
        let imageLicense = imageLicenses[0]
        
        var dataLicenseDelegate: DataLicenseScreenDelegate?
        
        let stepThirdViewController = factory.makeRegisterThreeStepScreen(user: user,
                                                                          service: registerService,
                                                                          dataLicense: dataLicense,
                                                                          imageLicense: imageLicense,
                                                                          onReadPrivacyPolicy: { _ in
                                                                            
                                                                          },
                                                                          onDataLicense: { [weak self] dataLicense in
                                                                            self?.showLicenseScreen(isDataLicense: true,
                                                                                                    dataLicenses: dataLicenses,
                                                                                                    presentDatePicker: dataLicenseDelegate)
                                                                          },
                                                                          onImageLicense: { [weak self] imageLicense in
                                                                            self?.showLicenseScreen(isDataLicense: false,
                                                                                                    dataLicenses: imageLicenses,
                                                                                                    presentDatePicker: dataLicenseDelegate)
                                                                          },
                                                                          onSuccess: { _ in },
                                                                          onError: { _ in })
        
        let viewController = stepThirdViewController as? UIHostingController<RegisterStepThreeScreen<RegisterStepThreeScreenViewModel>>
        dataLicenseDelegate = viewController?.rootView.loader
        
        stepThirdViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        stepThirdViewController.setBiologerTitle(text: "REGISTER STEP THREE")
        self.navigationController.pushViewController(stepThirdViewController, animated: true)
    }
    
    private func showLicenseScreen(isDataLicense: Bool,
                                   dataLicenses: [DataLicense],
                                   presentDatePicker: DataLicenseScreenDelegate?) {
        
        let dataLicenseViewController = factory.makeLicenseScreen(dataLicenses: dataLicenses,
                                                                  delegate: presentDatePicker) { [weak self] dataLicenses in
            self?.navigationController.popViewController(animated: true)
        }
        dataLicenseViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        dataLicenseViewController.setBiologerTitle(text: isDataLicense ? "DATA LICENSE" : "IMAGE LICENSE")
        self.navigationController.pushViewController(dataLicenseViewController, animated: true)
    }
    
    @objc func goBack() {
        navigationController.popViewController(animated: true)
    }
}
