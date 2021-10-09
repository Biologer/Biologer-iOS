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
                            Text(String(index) + ".")
                                .foregroundColor(Color.black)
                            Text(viewModel.codes[index].name)
                                .fixedSize(horizontal: false, vertical: true)
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
        .animation(.default)
        .background(Color.biologerGreenColor.opacity(0.4))
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct NestingAtlasCodeScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let viewModel = NestingAtlasCodeScreenViewModel(codes: [NestingAtlasCodeItem(name: "Species observed but supected to be on migration or to be summering non-beeder"),
        NestingAtlasCodeItem(name: "Species observed in breeding seasson in possible naesting habitat"), NestingAtlasCodeItem(name: "Singin male(s) present (or breeding calls heard) in breeading season"), NestingAtlasCodeItem(name: "Pair observed in suitable nesting habitat in breeding season"), NestingAtlasCodeItem(name: "Permanent territory presumed through registration of teritorial behaviour (song, etc) on at last two difference days a week or more apart at the same place"), NestingAtlasCodeItem(name: "Species observed but supected to be on migration or to be summering non-beeder"), NestingAtlasCodeItem(name: "Species observed but supected to be on migration or to be summering non-beeder"),
        NestingAtlasCodeItem(name: "Species observed in breeding seasson in possible naesting habitat"), NestingAtlasCodeItem(name: "Singin male(s) present (or breeding calls heard) in breeading season"), NestingAtlasCodeItem(name: "Pair observed in suitable nesting habitat in breeding season"), NestingAtlasCodeItem(name: "Permanent territory presumed through registration of teritorial behaviour (song, etc) on at last two difference days a week or more apart at the same place"), NestingAtlasCodeItem(name: "Species observed but supected to be on migration or to be summering non-beeder")],
                                                        previousSlectedCode: nil,
                                                        delegate: nil,
                                                        onCodeTapped: { _ in })
        
        NestingAtlasCodeScreen(viewModel: viewModel)
    }
}
