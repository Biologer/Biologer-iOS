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
                .frame(width: 20, height: 20)
            Text(title)
        }
        .frame(height: 50)
    }
}

struct MenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        MenuItemView(title: "List of findings", image: "env_icon")
    }
}
