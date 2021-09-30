//
//  NewTaxonImageView.swift
//  Biologer
//
//  Created by Nikola Popovic on 28.9.21..
//

import SwiftUI

struct NewTaxonImageView: View {
    
    @ObservedObject var viewModel: NewTaxonImageViewModel
    
    let columns = [
        GridItem(.adaptive(minimum: 40))
    ]
    
    var body: some View {
        HStack(alignment: .top) {
                Button(action: {
                    viewModel.fotoButtonTapped()
                }, label: {
                    Image(viewModel.fotoButtonImage)
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                })
                Button(action: {
                    viewModel.gallerButtonTapped()
                }, label: {
                    Image(viewModel.galleryButtonImage)
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                })
                
                if !viewModel.choosenImages.isEmpty {
                    ScrollView(.horizontal) {
                        HStack(alignment: .top) {
                            ForEach(viewModel.choosenImages.indices, id: \.self) { index in
                                Button(action: {
                                    viewModel.imageButtonTapped(selectedImageIndex: index)
                                }, label: {
                                    viewModel.choosenImages[index].image
                                        .resizable()
                                        .frame(width: 40, height: 50, alignment: .center)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                })
                                .padding(.horizontal,5)
                                .padding(.vertical, 1)
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.bottom, 10)
        }
}

struct NewTaxonImageView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = NewTaxonImageViewModel(choosenImages: [TaxonImage(image: Image("intro4")), TaxonImage(image: Image("intro4")), TaxonImage(image: Image("intro4")), TaxonImage(image: Image("intro4")), TaxonImage(image: Image("intro4"))],
                                               onFotoTapped: { _ in },
                                               onGalleryTapped: { _ in },
                                               onImageTapped: { _ in })
        NewTaxonImageView(viewModel: viewModel)
    }
}
