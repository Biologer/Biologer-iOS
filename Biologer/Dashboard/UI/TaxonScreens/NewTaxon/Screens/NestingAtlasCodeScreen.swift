//
//  NestingAtlasCodeScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.10.21..
//

import SwiftUI

struct NestingAtlasCodeScreen: View {
    
    @ObservedObject var viewModel: NestingAtlasCodeScreenViewModel
    
    var body: some View {
        ScrollView {
            ForEach(viewModel.codes.indices, id: \.self) { index in
                Button(action: {
                    viewModel.selectCode(viewModel.codes[index])
                }, label: {
                    VStack {
                        HStack(alignment: .top) {
//                            Text(String(index) + ".")
//                                .foregroundColor(Color.black)
                            Text(viewModel.codes[index].name)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(Color.black)
                            Spacer()
                            VStack {
                                Spacer()
                                Image(viewModel.codes[index].isSelected ? "check_mark" : "")
                                Spacer()
                            }
                        }
                        Divider()
                    }
                    .padding()
                })
            }
        }
        .navigationBarBackButtonHidden(true)
        .animation(.default)
        .background(Color.biologerGreenColor.opacity(0.4))
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct NestingAtlasCodeScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let viewModel = NestingAtlasCodeScreenViewModel(codes: NestingAtlasCodeMapper.getNestingCodes(),
                                                        previousSlectedCode: nil,
                                                        delegate: nil,
                                                        onCodeTapped: { _ in })
        
        NestingAtlasCodeScreen(viewModel: viewModel)
    }
}
