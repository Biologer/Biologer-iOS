//
//  EnvironmentLoginView.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import SwiftUI

struct EnvironmentLoginView: View {
    
    var environmentViewModel: EnvironmentViewModelProtocol
    var envImage: String
    
    var body: some View {
        HStack {
            Image(environmentViewModel.image)
                .resizable()
                .frame(width: 35, height: 35)
                .padding(.trailing, 20)
                .padding(.leading, 10)
            Text(environmentViewModel.title)
                .foregroundColor(.gray)
            Spacer()
            Image(envImage)
                .resizable()
                .frame(width: 35, height: 35)
                .padding(.trailing, 10)
        }
        .frame(height: 60)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}

struct EnvironmentLoginView_Previews: PreviewProvider {
    static var previews: some View {
        EnvironmentLoginView(environmentViewModel: StubEnvironmentViewModel(), envImage: "env_icon")
    }
    
    private class StubEnvironmentViewModel: EnvironmentViewModelProtocol {
        var title: String = "Serbia"
        var image: String = "hammer_icon"
        var host: String = "www.apple.com"
    }
}
