//
//  MapTypeScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 6.10.21..
//

import SwiftUI

struct MapTypeScreen: View {
    
    let viewModel: MapTypeScreenViewModel
    
    var body: some View {
        VStack {
            ForEach(viewModel.mapTypes, id: \.id) { type in
                Button(action: {
                    viewModel.typeTapped(type: type)
                }, label: {
                    VStack {
                        Text(type.name)
                            .foregroundColor(.black)
                        Divider()
                    }
                })
            }
        }
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 1.0)
                .foregroundColor(Color.clear)
                .shadow(color: Color.black, radius: 1, x: 0, y: 0)
        )
        .navigationBarBackButtonHidden(true)
        .frame(width: UIScreen.screenWidth * 0.6,
               alignment: .center)
    }
}

struct MapTypeScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = MapTypeScreenViewModel(delegate: nil,
                                               onTypeTapped: { _ in })
        
        MapTypeScreen(viewModel: viewModel)
    }
}
