//
//  ItemsListView.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.6.21..
//

import SwiftUI

struct FindingsListView: View {
    
    var items: [Item]
    var onItemTapped: Observer<Item>
    var onNewItemTapped: Observer<Void>
    
    var body: some View {
        VStack {
            List {
                ForEach(items, id: \.id) { item in
                    HStack {
                        Text(item.name)
                    }
                    .onTapGesture {
                        onItemTapped(item)
                    }
                }
            }
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

struct ItemsListView_Previews: PreviewProvider {
    
    static var previews: some View {
        FindingsListView(items: [Item(id: 1, name: "Item 1"),
                              Item(id: 2, name: "Item 2"),
                              Item(id: 3, name: "Item 3"),
                              Item(id: 4, name: "Item 4"),
                              Item(id: 5, name: "Item 5")], onItemTapped: { item in }, onNewItemTapped: { _ in }
                      )
    }
}
