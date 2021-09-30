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
    let onImageDeleteTapped: Observer<Int>
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top) {
                ForEach(images.indices, id: \.self) { index in
                        ZStack {
                            TaxonImageView(taxonImage: images[index])
                                .onTapGesture {
                                    onImageTapped((index))
                                }
                            VStack {
                                Spacer()
                                Button(action: {
                                    onImageDeleteTapped((index))
                                }, label: {
                                    Image("delete_image_icon")
                                        .frame(width: 20, height: 20)
                                })
                                .position(CGPoint(x: 40, y: 0))
                                Spacer()
                            }
                            .frame(width: 40, height: 55)
                        }
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
                            onImageTapped: { index in}, onImageDeleteTapped: { _ in})
    }
}
