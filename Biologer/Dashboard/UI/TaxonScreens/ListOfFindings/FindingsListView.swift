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
            Image("gallery_icon")
                .resizable()
                .frame(width: 45, height: 45, alignment: .center)
            Button(action: {
                onFindingTapped(())
            }, label: {
                VStack(alignment: .leading) {
                    Text(finding.taxon)
                        .foregroundColor(Color.black)
                        .font(.italic(.body)())
                    Text(finding.developmentStage)
                        .foregroundColor(Color.black)
                        .font(.callout)
                }
            })
            Spacer()
            Button(action: {
                onDeleteTapped(())
            }, label: {
                Image("bin_icon")
                    .resizable()
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
    var onNewItemTapped: Observer<Void>
    
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
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        onNewItemTapped(())
                    }, label: {
                        Image("add_token")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                    })
                    .padding()
                }
            }
        }
    }
}

struct ItemsListView_Previews: PreviewProvider {
    
    static var previews: some View {
        FindingsListView(items: [Finding(id: 1, taxon: "Zerynthia polyxena", developmentStage: "Larva"),
                                 Finding(id: 2, taxon: "Salamandra salamandra", developmentStage: "Adult"),
                                 Finding(id: 3, taxon: "Salamandra salamandra", developmentStage: "Adult"),Finding(id: 1, taxon: "Zerynthia polyxena", developmentStage: "Larva"),
                                 Finding(id: 2, taxon: "Salamandra salamandra", developmentStage: "Adult"),
                                 Finding(id: 3, taxon: "Salamandra salamandra", developmentStage: "Adult"),Finding(id: 1, taxon: "Zerynthia polyxena", developmentStage: "Larva"),
                                 Finding(id: 2, taxon: "Salamandra salamandra", developmentStage: "Adult"),
                                 Finding(id: 3, taxon: "Salamandra salamandra", developmentStage: "Adult"),Finding(id: 1, taxon: "Zerynthia polyxena", developmentStage: "Larva"),
                                 Finding(id: 2, taxon: "Salamandra salamandra", developmentStage: "Adult"),
                                 Finding(id: 3, taxon: "Salamandra salamandra", developmentStage: "Adult"),Finding(id: 1, taxon: "Zerynthia polyxena", developmentStage: "Larva"),
                                 Finding(id: 2, taxon: "Salamandra salamandra", developmentStage: "Adult"),
                                 Finding(id: 3, taxon: "Salamandra salamandra", developmentStage: "Adult")], onItemTapped: { item in }, onDeleteFindingTapped: { _ in }, onNewItemTapped: { _ in }
                      )
    }
}
