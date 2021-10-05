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
                    .foregroundColor(Color.black)
                    .font(.callout).bold()
                    .padding(.leading, 20)
                    .padding(.top, 10)
                Spacer()
            }
            content
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
        }
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 1)
                .foregroundColor(Color.clear)
                .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
        )
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

struct NewTaxonSectionView_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = NewTaxonLocationViewModel(location: LocationManager(),
                                                  onLocationTapped: { _ in})
        
        let view = NewTaxonLocationView(viewModel: viewModel)
        
        NewTaxonSectionView(title: "Location:",
                            content: {
                                view
        })
    }
}
