//
//  ImageHorizontalView.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import SwiftUI

struct ImageHorizontalView: View {
    
    let images: [Image]
    let onImageTapped: Observer<Int>
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top) {
                ForEach(images.indices, id: \.self) { index in
                    Button(action: {
                        onImageTapped((index))
                    }, label: {
                        TaxonImageView(taxonImage: images[index])
                    })
                    .padding(.horizontal,5)
                    .padding(.vertical, 1)
                }
            }
        }
        .padding()
    }
}

struct ImageHorizontalView_Previews: PreviewProvider {
    static var previews: some View {
        ImageHorizontalView(images: [Image("taxon_background"),
                                     Image("taxon_background"),
                                     Image("taxon_background"),
                                     Image("taxon_background"),
                                     Image("taxon_background")],
                            onImageTapped: { index in})
    }
}
