//
//  SetupSectionView.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import SwiftUI

struct SetupSectionView: View {
    
    @ObservedObject var viewModel: SetupSectionViewModel
    var onItemTapped: Observer<Int>
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(viewModel.title)
                .foregroundColor(Color.biologerGreenColor)
                .font(.headerBoldFont)
                .padding(.vertical, 10)
            ForEach(viewModel.items.indices) { index in
                let item = viewModel.items[index]
                Button(action: {
                    onItemTapped(index)
                }, label: {
                    SetupItemView(viewModel: item)
                })
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
                                        type: .projectName),
                     SetupItemViewModel(title: "Data License",
                                                     description: "Choose diffeten license four your data collected through the application",
                                                     isSelected: true,
                                                     type: .dataLicense),
                     SetupItemViewModel(title: "Image License",
                                                     description: "Choose diffeten license four your iamge sent through the application",
                                                     isSelected: true,
                                                     type: .imageLicense)]
        SetupSectionView(viewModel: SetupSectionViewModel(title: title,
                                                          items: items),
                         onItemTapped: { item in })
    }
}
