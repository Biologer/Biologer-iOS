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
            HStack {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.screenWidth/2)
                Spacer()
            }
            HStack {
                VStack(alignment:.leading, spacing: 0) {
                    Text(email)
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                    Text(username)
                            .foregroundColor(.white)
                            .font(.system(size: 10))
                }
                .padding()
                Spacer()
            }
            .padding(.top, 60)
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
