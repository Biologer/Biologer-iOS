//
//  PopUpYesAndNoScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.11.21..
//

import SwiftUI
import Lottie

struct PopUpYesAndNoScreen: View {
    
    var title: String
    var yesButtonTitle: String = "Common.btn.yes".localized
    var noButtonTitle: String = "Common.btn.no".localized
    var onYesTapped: Observer<Void>
    var onNoTapped: Observer<Void>
    
    let popUpWidth: CGFloat = UIScreen.screenWidth * 0.7
    
    var body: some View {
        VStack {
            LottieAnimationView(fileName: "lottie_question")
                .frame(width: 50, height: 50)
                .fixedSize()
                .padding(.vertical, 10)
            Text(title)
                .font(.headerFont)
                .multilineTextAlignment(.center)
                .frame(width: popUpWidth)
                .padding(.bottom, 5)
                .padding(.horizontal, 25)
            HStack {
                BiologerButton(title: yesButtonTitle,
                               width: popUpWidth / 3,
                               onTapped: onYesTapped)
                    .padding()
                BiologerButton(title: noButtonTitle,
                               width: popUpWidth / 3,
                               onTapped: onNoTapped)
                    .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.white)
        .frame(width: popUpWidth)
        .cornerRadius(20)
        .clipped()
        .shadow(color: Color.gray, radius: 10, x: 0, y: 0)
    }
}

struct PopUpYesAndNoScreen_Previews: PreviewProvider {
    static var previews: some View {
        PopUpYesAndNoScreen(title: "Do you want to download taxona?",
                            onYesTapped: { _ in }, onNoTapped: { _ in })
    }
}
