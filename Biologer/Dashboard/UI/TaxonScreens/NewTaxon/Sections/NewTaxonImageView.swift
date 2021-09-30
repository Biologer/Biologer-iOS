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
            AddImagesView(fotoButtonImage: viewModel.fotoButtonImage,
                          galleryButtonImage: viewModel.galleryButtonImage,
                          fotoButtonTapped: { _ in
                            viewModel.fotoButtonTapped()
                          },
                          gallerButtonTapped: { _ in
                            viewModel.gallerButtonTapped()
                          })
                .padding(.trailing, 10)
                
            VStack(alignment: .center) {
                if !viewModel.choosenImages.isEmpty {
                    ImageHorizontalView(images: viewModel.choosenImages.map({$0.image}),
                                        onImageTapped: { index in
                                            viewModel.imageButtonTapped(selectedImageIndex: index)
                                        },
                                        onImageDeleteTapped: { index in
                                            viewModel.delteImage(at: index)
                                        })
                } else {
                    NoImagesAddedView(title: viewModel.noImagesAdded)
                }
            }
            .frame(
                  minWidth: 0,
                  maxWidth: .infinity,
                  minHeight: 90,
                  maxHeight: .infinity,
                  alignment: .topLeading
                )
            .background(Color.gray.opacity(0.1))
            .cornerRadius(5)
                Spacer()
            }
            .padding(.bottom, 10)
        }
}

struct NewTaxonImageView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = NewTaxonImageViewModel(choosenImages: [TaxonImage(image: Image("intro4")), TaxonImage(image: Image("img_placeholder_icon")), TaxonImage(image: Image("intro4")), TaxonImage(image: Image("img_placeholder_icon")), TaxonImage(image: Image("intro4"))],
                                               onFotoTapped: { _ in },
                                               onGalleryTapped: { _ in },
                                               onImageTapped: { _ in })
        NewTaxonImageView(viewModel: viewModel)
    }
}
