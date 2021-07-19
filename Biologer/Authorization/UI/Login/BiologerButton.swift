//
//  BiologerButton.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import SwiftUI

struct BiologerButton: View {
    
    var title: String
    var onTapped: Observer<Void>
    
    var body: some View {
        Button(action: {
            onTapped(())
        }, label: {
            Text(title)
                .bold()
                .foregroundColor(Color.white)
                .frame(width: UIScreen.main.bounds.width * 0.6, height: 50, alignment: .center)
        })
        .background(Color.biologerGreenColor)
        .cornerRadius(5)
    }
}

struct LoginButton_Previews: PreviewProvider {
    static var previews: some View {
        BiologerButton(title: "LOG IN", onTapped: { _ in })
    }
}
