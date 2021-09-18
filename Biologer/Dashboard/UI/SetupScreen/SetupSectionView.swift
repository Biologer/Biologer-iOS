//
//  SetupSectionView.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import SwiftUI

struct SetupSectionView: View {
    
    @ObservedObject var viewModel: SetupSectionViewModel
    var onItemTapped: Observer<SetupItemViewModel>
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(viewModel.title)
                .foregroundColor(Color.biologerGreenColor)
                .font(.title3).bold()
                .padding(.vertical, 20)
            ForEach(viewModel.items) { item in
                SetupItemView(viewModel: item,
                              onItemTapped: onItemTapped)
                    .padding(.bottom, 20)
            }
            Divider()
                .padding(.top, -20)
        }
    }
}

struct SetupSectionView_Previews: PreviewProvider {
    static var previews: some View {
        let title = "User Account"
        let items = [SetupItemViewModel(title: "Project Name",
                                        description: "Sets the project title if your data was collected during a project",
                                        isSelected: true,
                                        onItemTapped: { _ in }),
                     SetupItemViewModel(title: "Data License",
                                                     description: "Choose diffeten license four your data collected through the application",
                                                     isSelected: true,
                                                     onItemTapped: { _ in }),
                     SetupItemViewModel(title: "Image License",
                                                     description: "Choose diffeten license four your iamge sent through the application",
                                                     isSelected: true,
                                                     onItemTapped: { _ in })]
        SetupSectionView(viewModel: SetupSectionViewModel(title: title,
                                                          items: items),
                         onItemTapped: { item in })
    }
}
