//
//  FoundDeadView.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import SwiftUI

struct FoundDeadView: View {
    var isCehcked: Bool
    var checkText: String
    var onCheckMarkTapped: Observer<Void>
    var textFieldViewModel: MaterialDesignTextFieldViewModelProtocol
    
    var body: some View {
        VStack {
            HStack {
                CheckView(isChecked: isCehcked,
                          onToggle: { _ in
                            onCheckMarkTapped(())
                          })
                Text(checkText)
                Spacer()
            }
            if isCehcked {
                MaterialDesignTextField(viewModel: textFieldViewModel,
                                        onTextChanged: { text in
                                            
                                        },
                                        textAligment: .left)
                    .frame(height: 50)
                    .padding(.bottom, 10)
            }
        }
    }
}

struct FoundDeadView_Previews: PreviewProvider {
    static var previews: some View {
        FoundDeadView(isCehcked: true,
                      checkText: "NewTaxon.tf.foundDead.text".localized,
                      onCheckMarkTapped: { _ in },
                      textFieldViewModel: FoundDeadTextField())
    }
}
