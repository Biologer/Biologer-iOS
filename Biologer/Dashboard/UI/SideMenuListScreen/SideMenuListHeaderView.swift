//
//  SideMenuListHeaderView.swift
//  Biologer
//
//  Created by Nikola Popovic on 15.6.21..
//

import SwiftUI

struct SideMenuListHeaderView: View {
    
    let image: String
    let email: String
    let username: String
    
    var body: some View {
        ZStack {
            Image(image)
                .resizable()
                .frame(height: 200)
            HStack {
                VStack(alignment:.leading, spacing: 10) {
                    Text(email)
                        .foregroundColor(.white)
                        .font(.system(size: 28))
                    Text(username)
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                }
                .padding()
                Spacer()
            }
            .padding(.top, 100)
            .frame(width: UIScreen.screenWidth)
        }
    }
}

struct SideMenuListHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuListHeaderView(image: "biloger_background",
                               email: "test@test.com",
                               username: "Nikola")
    }
}
