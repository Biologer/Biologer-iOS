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
                .scaledToFill()
            HStack {
                VStack(alignment:.leading, spacing: 5) {
                    Text(email)
                        .foregroundColor(.white)
                        .font(.paragraphTitleFont)
                    Text(username)
                        .foregroundColor(.white)
                        .font(.descriptionFont)
                }
                .padding(.bottom, 15)
                .padding(.leading, 15)
                Spacer()
            }
            .padding(.top, 60)
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
