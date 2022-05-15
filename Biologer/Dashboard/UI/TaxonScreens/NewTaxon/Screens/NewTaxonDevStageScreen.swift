//
//  NewTaxonDevStageScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 3.10.21..
//

import SwiftUI

struct NewTaxonDevStageScreen: View {
    
    let viewModel: NewTaxonDevStageScreenViewModel
    let heightCell: CGFloat = 40
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.stages, id: \.id) { stage in
                    Button(action: {
                        viewModel.stageSelect(stage: stage)
                    }, label: {
                        VStack {
                            Text(stage.name)
                                .foregroundColor(Color.black)
                                .font(.titleFont)
                                .padding(5)
                            Divider()
                        }
                    })
                }
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

        .frame(width: UIScreen.screenWidth * 0.6,
               height: UIScreen.screenHeight * 0.3,
               alignment: .center)
    }
}

struct NewTaxonDevStageScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = NewTaxonDevStageScreenViewModel(stages: [DevStageViewModel(id: 1, name: "Egg"), DevStageViewModel(id: 2, name: "Larva"),
                                                                 DevStageViewModel(id: 3, name: "Pupa"), DevStageViewModel(id: 4, name: "Adult")], delegate: nil, onDone: { _ in})
        
        NewTaxonDevStageScreen(viewModel: viewModel)
    }
}
