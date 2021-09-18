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
                .frame(width: 30, height: 30, alignment: .center)
            Text(viewModel.title)
                .font(.title3)
                .foregroundColor(Color.black)
        }
    }
}

struct RadioAndTitleView_Previews: PreviewProvider {
    static var previews: some View {
        RadioAndTitleView(viewModel: SetupRadioAndTitleModel(isSelected: true, title: "Always ask user"))
    }
}
