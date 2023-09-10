//
//  LogoutScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.7.21..
//

import SwiftUI

protocol LogoutScreenLoader: ObservableObject {
    var currentEnvDescription: String { get }
    var currentEnv: String { get }
    var asUser: String { get }
    var userEmail: String { get }
    var username: String { get }
    var bottomLogoutDescription: String { get }
    var logoutButtonTitle: String { get }
    func logoutTapped()
}

struct LogoutScreen<ScreenLoader>: View where ScreenLoader: LogoutScreenLoader {
    
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
            Text(loader.bottomLogoutDescription)
                .font(.headerFont)
                .multilineTextAlignment(.center)
                .padding(.bottom, 60)
            BiologerButton(title: loader.logoutButtonTitle,
                           onTapped: {
                            self.loader.logoutTapped()
                           })
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .padding(.leading, 30)
        .padding(.trailing, 30)
    }
}

struct LogoutScreen_Previews: PreviewProvider {
    static var previews: some View {
        LogoutScreen(loader: StubLogoutScreenLoader())
    }
    
    private class StubLogoutScreenLoader: LogoutScreenLoader {
        let currentEnvDescription: String = "You are currently loged into a datebase:"
        let currentEnv: String = "https://dev.biologer.org"
        let asUser: String = "As user:"
        let userEmail: String = "test@gmail.com"
        let username: String = "Pera Peric"
        let bottomLogoutDescription: String = "Do you want to logout from this Biologer database?"
        let logoutButtonTitle: String = "LOGOUT"
        func logoutTapped() {}
    }
}
