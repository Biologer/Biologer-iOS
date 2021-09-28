//
//  NewTaxonSectionView.swift
//  Biologer
//
//  Created by Nikola Popovic on 28.9.21..
//

import SwiftUI

struct NewTaxonSectionView<Content: View>: View {
    
    let content: Content
    let title: String

    init(title: String,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .foregroundColor(Color.biologerGreenColor)
                    .font(.title3).bold()
                    .padding(20)
                Spacer()
            }
            content
                .padding(.horizontal, 20)
            Divider()
        }
    }
}

struct NewTaxonSectionView_Previews: PreviewProvider {
    static var previews: some View {
        NewTaxonSectionView(title: "Location:",
                            content: {
            Text("Test")
        })
    }
}
