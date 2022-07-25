//
//  DeleteAccountScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 25.7.22..
//

import Foundation

public class DeleteAccountScreenViewModel: DeleteAccountScreenLoader {
    let currentEnvDescription: String = "DeleteAccount.lb.currentlyDB".localized
    let currentEnv: String
    let asUser: String = "DeleteAccount.lb.asUser".localized
    let userEmail: String
    let username: String
    let bottomDeleteAccountDescription: String = "DeleteAccount.lb.doYouWantLogout".localized
    let deleteButtonTitle: String = "DeleteAccount.btn.deleteAccount".localized
    
    private let onDeleteAccountTapped: Observer<Void>
    
    init(userEmail: String,
         username: String,
         currentEnv: String,
         onDeleteAccountTapped: @escaping Observer<Void>) {
        self.username = username
        self.userEmail = userEmail
        self.currentEnv = currentEnv
        self.onDeleteAccountTapped = onDeleteAccountTapped
    }

    func deleteTapped() {
        onDeleteAccountTapped(())
    }
}
