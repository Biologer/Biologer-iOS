//
//  SetupProjectNameScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import SwiftUI

struct SetupProjectNameScreen: View {
    
    var viewModel: SetupProjectNameScreenViewModel
    private let widthButtons: CGFloat = UIScreen.screenWidth * 0.3
    private let widthOfPopUp: CGFloat = UIScreen.screenWidth * 0.8
    private let heightOfPopUp: CGFloat = UIScreen.screenHeight * 0.2
    
    var body: some View {
        VStack(alignment: .center) {
            MaterialDesignTextField(viewModel: viewModel.textField,
                                    onTextChanged: { text in
                                        viewModel.textField.text = text
                                        viewModel.textField.type = .success
                                    },
                                    textAligment: .left)
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .frame(height: 100)
            HStack(spacing: 20) {
                BiologerButton(title: viewModel.cancelTitle,
                               width: widthButtons,
                               onTapped: { _ in
                                    viewModel.cancelTapped()
                               })
                BiologerButton(title: viewModel.okButtonTitle,
                               width: widthButtons,
                               onTapped: { _ in
                                    viewModel.okTapped()
                               })
            }
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .cornerRadius(20)
        .frame(width: widthOfPopUp, alignment: .center)
        .clipped()
        .shadow(color: Color.gray, radius: 10, x: 0, y: 0)
    }
}

struct ProjectNameScreen_Previews: PreviewProvider {
    static var previews: some View {
        SetupProjectNameScreen(viewModel: SetupProjectNameScreenViewModel(settingsStorage: UserDefaultsSettingsStorage(),
                                                                          onCancelTapped: { _ in }, onOkTapped: { _ in }))
    }
}
