//
//  RadioAndTitleView.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import SwiftUI

struct RadioAndTitleView: View {
    
    @ObservedObject var viewModel: SetupRadioAndTitleModel
    
    var body: some View {
        HStack {
            Image(viewModel.isSelected ? "radio_checked" : "radio_unchecked")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25, alignment: .center)
            Text(viewModel.title)
                .font(.titleFont)
                .foregroundColor(Color.black)
        }
    }
}

struct RadioAndTitleView_Previews: PreviewProvider {
    static var previews: some View {
        RadioAndTitleView(viewModel: SetupRadioAndTitleModel(isSelected: true,
                                                             title: "Always ask user",
                                                             type: .alwaysAskUser))
    }
}
