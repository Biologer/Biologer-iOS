//
//  LoginEnvView.swift
//  Biologer
//
//  Created by Nikola Popovic on 12.7.21..
//

import SwiftUI

struct LoginEnvView: View {
    
    public var environmentPlacehoder: String
    public var viewModel: EnvironmentViewModel
    public var onEnvTapped: Observer<EnvironmentViewModel>
    
    var body: some View {
        
        Button(action: {
            onEnvTapped((viewModel))
        }, label: {
            VStack(alignment: .leading) {
                Text(environmentPlacehoder)
                    .font(.descriptionFont)
                    .foregroundColor(Color.black)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Image(viewModel.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    Text(viewModel.title)
                        .font(.titleFont)
                        .foregroundColor(Color.black)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                        Image("right_arrow")
                }
                Divider()
                    .padding(.top, 4)
            }
        })
    }
}

struct LoginEnvView_Previews: PreviewProvider {
    static var previews: some View {
        LoginEnvView(environmentPlacehoder: "Selecte Environment",
                     viewModel: EnvironmentViewModel(id: 1,
                                                     title: "Serbia",
                                                     image: "serbia_flag",
                                                     env: Environment(host: serbiaHost, path: serbiaLangPath, clientSecret: serbiaClientSecret, cliendId: cliendIdSer),
                                                      isSelected: false), onEnvTapped: { _ in })
    }
}
