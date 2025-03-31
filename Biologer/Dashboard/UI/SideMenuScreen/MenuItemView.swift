//
//  MenuItemView.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.6.21..
//

import SwiftUI

struct MenuItemView: View {
    
    var title: String
    var image: String
    
    var body: some View {
        HStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            Text(title)
                .font(.headerFont)
        }
        .frame(height: 50)
    }
}

struct MenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        MenuItemView(title: "List of findings", image: "env_icon")
    }
}
