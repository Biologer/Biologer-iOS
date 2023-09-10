//
//  SetupItemView.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import SwiftUI

struct SetupItemView: View {
    
    @ObservedObject var viewModel: SetupItemViewModel
    private let imageSize: CGFloat = 30
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.title)
                .multilineTextAlignment(.leading)
                .font(.headerFont)
                .padding(.bottom, 5)
                .foregroundColor(Color.black)
            HStack(alignment: .center) {
                Text(viewModel.description)
                    .multilineTextAlignment(.leading)
                    .font(.titleFont)
                    .foregroundColor(Color.gray)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                if let selection = viewModel.isSelected {
                    Image(selection ? "checked_green_icon" : "unchecked_green_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize, height: imageSize, alignment: .center)
                }
            }
        }
    }
}

struct SetupItemView_Previews: PreviewProvider {
    static var previews: some View {
        SetupItemView(viewModel: SetupItemViewModel(title: "Project Name",
                                                    description: "Sets the project title if your data was collected during a project",
                                                    isSelected: true,
                                                    type: .projectName))
    }
}
