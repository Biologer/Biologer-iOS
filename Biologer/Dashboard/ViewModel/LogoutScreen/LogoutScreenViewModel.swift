//
//  LogoutScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.7.21..
//

import Foundation

public final class LogoutScreenViewModel: LogoutScreenLoader {
    let currentEnvDescription: String = "Logout.lb.currentlyDB".localized
    let currentEnv: String = "https://dev.biologer.org"
    let asUser: String = "Logout.lb.asUser".localized
    let userEmail: String = "test@gmail.com"
    let username: String = "Pera Peric"
    let bottomLogoutDescription: String = "Logout.lb.doYouWantLogout".localized
    let logoutButtonTitle: String = "Logout.btn.logout".localized
    
    private let onLogoutTapped: Observer<Void>
    
    init(onLogoutTapped: @escaping Observer<Void>) {
        self.onLogoutTapped = onLogoutTapped
    }
    
    func logoutTapped() {
        onLogoutTapped(())
    }
}
