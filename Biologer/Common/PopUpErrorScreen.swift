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
            Text(title)
                .padding(20)
                .font(.headline)
            Text(description)
                .padding()
                .font(.subheadline)
            BiologerButton(title: buttonTitle,
                           width: popUpWidth / 2,
                           onTapped: onButtonTapped)
                .padding()
        }
        .background(Color.white)
        .cornerRadius(20)
        .frame(width: popUpWidth)
        .clipped()
        .shadow(color: Color.gray, radius: 10, x: 0, y: 0)
    }
}

struct PopUpErrorScreen_Previews: PreviewProvider {
    static var previews: some View {
        PopUpErrorScreen(title: "Error",
                         description: "Some description about error Some description about error Some description about error Some description about error Some description about error Some description about error",
                         onButtonTapped: { _ in })
    }
}
