//
//  SetupItemView.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import SwiftUI

struct SetupItemView: View {
    
    @ObservedObject var viewModel: SetupItemViewModel
    var onItemTapped: Observer<SetupItemViewModel>
    private let imageSize: CGFloat = 30
    
    var body: some View {
        
        Button(action: {
            onItemTapped((viewModel))
        }, label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.title)
                        .font(.title2)
                        .padding(.bottom, 5)
                        .foregroundColor(Color.black)
                    Text(viewModel.description)
                        .font(.callout)
                        .foregroundColor(Color.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                if let selection = viewModel.isSelected {
                    Image(selection ? "checked_green_icon" : "unchecked_green_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize, height: imageSize, alignment: .center)
                }
            }
        })
    }
}

struct SetupItemView_Previews: PreviewProvider {
    static var previews: some View {
        SetupItemView(viewModel: SetupItemViewModel(title: "Project Name",
                                                    description: "Sets the project title if your data was collected during a project",
                                                    isSelected: true,
                                                    onItemTapped: { _ in }),
                      onItemTapped: { item in })
    }
}
