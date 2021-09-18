//
//  BiologerButton.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import SwiftUI

struct BiologerButton: View {
    
    var title: String
    var width: CGFloat?
    private let defaultWidth: CGFloat = UIScreen.main.bounds.width * 0.6
    var onTapped: Observer<Void>
    
    var body: some View {
        Button(action: {
            onTapped(())
        }, label: {
            Text(title)
                .bold()
                .foregroundColor(Color.white)
                .frame(width: width ?? defaultWidth, height: 50, alignment: .center)
        })
        .background(Color.biologerGreenColor)
        .cornerRadius(5)
        .clipped()
        .shadow(color: Color.gray, radius: 5, x: 0, y: 0)

    }
}

struct LoginButton_Previews: PreviewProvider {
    static var previews: some View {
        BiologerButton(title: "LOG IN", onTapped: { _ in })
    }
}
