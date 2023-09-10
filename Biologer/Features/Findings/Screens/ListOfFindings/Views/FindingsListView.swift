//
//  ItemsListView.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.6.21..
//

import SwiftUI

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
        FindingsListView(items: FindingModelFactory.getFindgins(),
                         onItemTapped: { item in },
                         onDeleteFindingTapped: { _ in }
                      )
    }
}
