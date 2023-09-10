//
//  LogoutScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.7.21..
//

import Foundation

public final class LogoutScreenViewModel: LogoutScreenLoader {
    let currentEnvDescription: String = "Logout.lb.currentlyDB".localized
    let currentEnv: String
    let asUser: String = "Logout.lb.asUser".localized
    let userEmail: String
    let username: String
    let bottomLogoutDescription: String = "Logout.lb.doYouWantLogout".localized
    let logoutButtonTitle: String = "Logout.btn.logout".localized
    
    private let onLogoutTapped: Observer<Void>
    
    init(userEmail: String,
         username: String,
         currentEnv: String,
         onLogoutTapped: @escaping Observer<Void>) {
        self.username = username
        self.userEmail = userEmail
        self.currentEnv = currentEnv
        self.onLogoutTapped = onLogoutTapped
    }
    
    func logoutTapped() {
        onLogoutTapped(())
    }
}
