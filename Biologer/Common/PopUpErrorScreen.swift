//
//  PopUpErrorScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 13.9.21..
//

import SwiftUI

struct PopUpErrorScreen: View {
    
    var title: String
    var description: String
    var onButtonTapped: Observer<Void>
    var buttonTitle: String = "Common.btn.ok".localized
    let popUpWidth: CGFloat = UIScreen.screenWidth * 0.7
    
    var body: some View {
        VStack {
            Text("API.lb.error".localized)
                .font(.title2).bold()
                .multilineTextAlignment(.center)
                .frame(width: popUpWidth)
                .padding(20)
            Text(title)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
                .padding(.horizontal, 10)
            Text(description)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .padding(.horizontal, 10)
            BiologerButton(title: buttonTitle,
                           width: popUpWidth / 3,
                           onTapped: onButtonTapped)
                .padding()
        }
        .background(Color.white)
        .frame(width: popUpWidth)
        .cornerRadius(20)
        .clipped()
        .shadow(color: Color.gray, radius: 10, x: 0, y: 0)
    }
}

struct PopUpErrorScreen_Previews: PreviewProvider {
    static var previews: some View {
        PopUpErrorScreen(title: " Authentication issue",
                         description: "Please try again later..",
                         onButtonTapped: { _ in })
    }
}
