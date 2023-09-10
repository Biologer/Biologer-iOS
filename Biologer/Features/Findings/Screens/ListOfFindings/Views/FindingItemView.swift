//
//  FindingItemView.swift
//  Biologer
//
//  Created by Nikola Popovic on 10.9.23..
//

import SwiftUI

struct FindingItemView: View {
    
    var finding: Finding
    let onFindingTapped: Observer<Void>
    let onDeleteTapped: Observer<Void>
    
    var body: some View {
        HStack {
            Image(uiImage: finding.getFindingImage)
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45, alignment: .center)
            Button(action: {
                onFindingTapped(())
            }, label: {
                VStack(alignment: .leading) {
                    Text(finding.taxon)
                        .foregroundColor(Color.black)
                        .font(.titleFontItalic)
                    Text(finding.developmentStage)
                        .foregroundColor(Color.black)
                        .font(.titleFont)
                }
            })
            Spacer()
            Image(finding.isUploaded ? "uploaded_icon" : "unuploaded_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30, alignment: .center)
            Button(action: {
                onDeleteTapped(())
            }, label: {
                Image("bin_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30, alignment: .center)
            })
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 1)
                .foregroundColor(Color.clear)
                .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
        )
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
    }
}
