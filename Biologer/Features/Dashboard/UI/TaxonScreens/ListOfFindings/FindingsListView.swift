//
//  ItemsListView.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.6.21..
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

struct FindingsListView: View {
    
    var items: [Finding]
    var onItemTapped: Observer<Finding>
    var onDeleteFindingTapped: Observer<Finding>
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    VStack {
                        Color.clear
                        ForEach(items, id: \.id) { finding in
                            FindingItemView(finding: finding,
                                            onFindingTapped: { _ in
                                                onItemTapped((finding))
                                            },
                                            onDeleteTapped: { _ in
                                                onDeleteFindingTapped((finding))
                                            })
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

struct ItemsListView_Previews: PreviewProvider {
    
    static var previews: some View {
        FindingsListView(items: [Finding(id: UUID(), taxon: "Zerynthia polyxena", image: UIImage(), developmentStage: "Larva", isUploaded: false),
                                 Finding(id: UUID(), taxon: "Salamandra salamandra", image: UIImage(), developmentStage: "Adult", isUploaded: true),
                                 Finding(id: UUID(), taxon: "Salamandra salamandra", image: UIImage(), developmentStage: "Adult", isUploaded: false)], onItemTapped: { item in }, onDeleteFindingTapped: { _ in }
                      )
    }
}
