//
//  LoginEnvView.swift
//  Biologer
//
//  Created by Nikola Popovic on 12.7.21..
//

import SwiftUI

struct LoginEnvView: View {
    
    public var viewModel: EnvironmentViewModel
    public var onEnvTapped: Observer<EnvironmentViewModel>
    
    var body: some View {
        
        Button(action: {
            onEnvTapped((viewModel))
        }, label: {
            VStack(alignment: .leading) {
                Text(viewModel.placeholder)
                    .font(.system(size: 12))
                    .foregroundColor(Color.black)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Image(viewModel.image)
                        //.padding([.leading, .trailing], 8)
                    Text(viewModel.title)
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
        LoginEnvView(viewModel: EnvironmentViewModel(id: 1, title: "Srbija", placeholder: "Select Environment", image: "serbia_flag", host: "www.apple.com", path: "/sr", isSelected: false), onEnvTapped: { _ in })
    }
}
