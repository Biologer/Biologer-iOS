//
//  LogoutScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.7.21..
//

import Foundation

public final class LogoutScreenViewModel: LogoutScreenLoader {
    let currentEnvDescription: String = "You are currently loged into a datebase:"
    let currentEnv: String = "https://dev.biologer.org"
    let asUser: String = "As user:"
    let userEmail: String = "test@gmail.com"
    let username: String = "Pera Peric"
    let bottomLogoutDescription: String = "Do you want to logout from this Biologer database?"
    let logoutButtonTitle: String = "LOGOUT"
    
    private let onLogoutTapped: Observer<Void>
    
    init(onLogoutTapped: @escaping Observer<Void>) {
        self.onLogoutTapped = onLogoutTapped
    }
    
    func logoutTapped() {
        onLogoutTapped(())
    }
}
