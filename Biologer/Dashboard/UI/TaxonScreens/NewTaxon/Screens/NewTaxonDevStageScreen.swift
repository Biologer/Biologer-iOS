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
                                .padding(5)
                            Divider()
                        }
                    })
                }
            }
        }
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(20)
        .frame(width: UIScreen.screenWidth * 0.6,
               height: UIScreen.screenHeight * 0.3,
               alignment: .center)
    }
}

struct NewTaxonDevStageScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = NewTaxonDevStageScreenViewModel(stages: [DevStageViewModel(name: "Egg"), DevStageViewModel(name: "Larva"),
                                                                 DevStageViewModel(name: "Pupa"), DevStageViewModel(name: "Adult")], delegate: nil, onDone: { _ in})
        
        NewTaxonDevStageScreen(viewModel: viewModel)
    }
}
