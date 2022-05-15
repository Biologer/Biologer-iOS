//
//  PopUpConfirmScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 13.9.21..
//

import SwiftUI

public enum PopUpType {
    case warning
    case error
    case success
    case question
    case info
    case basic
}

struct PopUpConfirmScreen: View {
    var popUpType: PopUpType
    var title: String
    var description: String
    var onButtonTapped: Observer<Void>
    var buttonTitle: String = "Common.btn.ok".localized
    let popUpWidth: CGFloat = UIScreen.screenWidth * 0.7
    
    var getAnimationByType: String {
        switch popUpType {
        case .warning:
            return "lottie_warning"
        case .error:
            return "lottie_error"
        case .success:
            return "lottie_success"
        case .question:
            return "lottie_question"
        case .info:
            return "lottie_info"
        case .basic:
            return ""
        }
    }
    
    var body: some View {
        VStack {
            if getAnimationByType != "" {
                LottieAnimationView(fileName: getAnimationByType)
                    .frame(width: 50, height: 50)
                    .fixedSize()
                    .padding(.top, 10)
            }
            Text(title)
                .font(.paragraphTitleBoldFont)
                .frame(width: popUpWidth)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
                .padding(.horizontal, 10)
            Text(description)
                .multilineTextAlignment(.center)
                .font(.headerFont)
                .padding(.horizontal, 10)
            BiologerButton(title: buttonTitle,
                           width: popUpWidth / 3,
                           onTapped: onButtonTapped)
                .padding(.vertical, 15)
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
        PopUpConfirmScreen(popUpType: .question,
                           title: " Authentication issue",
                           description: "Please try again later..",
                           onButtonTapped: { _ in })
    }
}

