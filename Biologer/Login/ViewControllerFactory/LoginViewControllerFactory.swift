//
//  LoginViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.4.21..
//

import UIKit

public protocol LoginViewControllerFactory {
    func presentLoginScreen(onSelectEnvironmentTapped: @escaping Observer<Void>,
                                   onLoginTapped: @escaping Observer<Void>,
                                   onRegisterTapped: @escaping Observer<Void>,
                                   onForgotPasswordTapped: @escaping Observer<Void>
                                   ) -> UIViewController
}
