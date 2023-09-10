//
//  BiologerProgressBarScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 6.11.21..
//

import SwiftUI

struct BiologerProgressBarScreen: View {
    
    @ObservedObject var viewModel: BiologerProgressBarScreenViewModel
    private let popUpWidth: CGFloat = UIScreen.screenWidth * 0.7

     var body: some View {
         VStack {
            ProgressView(viewModel.getTitle(),
                         value: viewModel.currentValue,
                         total: viewModel.maxValue)
                .progressViewStyle(LinearProgressViewStyle(tint: .biologerGreenColor))
                .padding(20)
            HStack {
                BiologerButton(title: viewModel.cancelButtonTitle,
                               width: popUpWidth / 3,
                               onTapped: { _ in
                                viewModel.cancelTapped()
                               })
                    .padding(.bottom, 20)
            }
         }
         .onAppear {
            viewModel.progressBarAppeared()
         }
         .animation(.default)
         .background(Color.white)
         .frame(width: popUpWidth)
         .cornerRadius(20)
         .clipped()
         .shadow(color: Color.gray, radius: 10, x: 0, y: 0)
     }
}

struct TaxonPogressView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = BiologerProgressBarScreenViewModel(maxValue: 10.0,
                                              currentValue: 10.0,
                                              onProgressAppeared: { _ in },
                                              onCancelTapped: {_ in })
        BiologerProgressBarScreen(viewModel: viewModel)
    }
}
