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
    var buttonTitle: String = "OK"
    let popUpWidth: CGFloat = UIScreen.screenWidth * 0.7
    
    var body: some View {
        VStack {
            Text("Error")
                .font(.title2).bold()
                .frame(width: popUpWidth)
                .padding(20)
            Text(title)
                .padding(.bottom, 5)
                .padding(.horizontal, 10)
                .font(.title3)
            Text(description)
                .padding(.horizontal, 10)
                .font(.subheadline)
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
