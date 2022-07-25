//
//  DeleteAccountScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 25.7.22..
//

import SwiftUI

protocol DeleteAccountScreenLoader: ObservableObject {
    var currentEnvDescription: String { get }
    var currentEnv: String { get }
    var asUser: String { get }
    var userEmail: String { get }
    var username: String { get }
    var bottomDeleteAccountDescription: String { get }
    var deleteButtonTitle: String { get }
    func deleteTapped()
}

struct DeleteAccountScreen<ScreenLoader>: View where ScreenLoader: DeleteAccountScreenLoader {
    
    @ObservedObject var loader: ScreenLoader
    
    var body: some View {
        VStack {
            Text(loader.currentEnvDescription)
                .font(.headerFont)
                .multilineTextAlignment(.center)
                .padding(.top, 30)
            Text(loader.currentEnv)
                .font(.headerFont)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            Text(loader.asUser)
                .font(.headerFont)
                .multilineTextAlignment(.center)
            Text(loader.userEmail)
                .font(.headerFont)
                .multilineTextAlignment(.center)
            Text(loader.username)
                .font(.headerBoldFont)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            Text(loader.bottomDeleteAccountDescription)
                .font(.headerFont)
                .multilineTextAlignment(.center)
                .padding(.bottom, 60)
            BiologerButton(title: loader.deleteButtonTitle,
                           onTapped: {
                                self.loader.deleteTapped()
                           })
            Spacer()
        }
        .padding(.leading, 30)
        .padding(.trailing, 30)
    }
}

struct DeleteAccountScreen_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountScreen(loader: StubDeleteAccountScreenLoader())
    }
    
    private class StubDeleteAccountScreenLoader: DeleteAccountScreenLoader {
        let currentEnvDescription: String = "You are currently loged into a datebase:"
        let currentEnv: String = "https://dev.biologer.org"
        let asUser: String = "As user:"
        let userEmail: String = "test@gmail.com"
        let username: String = "Pera Peric"
        let bottomDeleteAccountDescription: String = "Do you want to delete account from this Biologer database?"
        let deleteButtonTitle: String = "DELETE ACCOUNT"
        func deleteTapped() {}
    }
}
