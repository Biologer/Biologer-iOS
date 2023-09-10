//
//  SetupDownloadAndUploadScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import SwiftUI

struct SetupDownloadAndUploadScreen: View {
    
    @ObservedObject var viewModel: SetupDownloadAndUploadScreenViewModel
    private let widthButton: CGFloat = UIScreen.screenWidth * 0.2
    private let widthPopUp: CGFloat = UIScreen.screenWidth * 0.8
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.title)
                .font(.headerBoldFont)
                .foregroundColor(Color.black)
            ForEach(viewModel.items.indices, id: \.self) { index in
                let item = viewModel.items[index]
                Button(action: {
                    viewModel.itemTapped(selectedIndex: index)
                }, label: {
                    RadioAndTitleView(viewModel: item)
                })
            }
            HStack(alignment: .center) {
                Spacer()
                BiologerButton(title: viewModel.cancelButtonTitle,
                               width: widthButton,
                               onTapped: { _ in
                                viewModel.cancelTapped()
                               })
                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .frame(width: widthPopUp)
        .clipped()
        .shadow(color: Color.gray, radius: 10, x: 0, y: 0)
    }
}

struct SetupDownloadAndUploadScreen_Previews: PreviewProvider {
        static var previews: some View {
            SetupDownloadAndUploadScreen(viewModel: SetupDownloadAndUploadScreenViewModel(settingsStorage: UserDefaultsSettingsStorage(),
                                                                                          onCancelTapped: { _ in },
                                                                                          onItemTapped: { _ in }))
    }
}
