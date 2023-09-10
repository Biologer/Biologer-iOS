//
//  NewFindingImageView.swift
//  Biologer
//
//  Created by Nikola Popovic on 28.9.21..
//

import SwiftUI

struct NewFindingImageView: View {
    
    @ObservedObject var viewModel: NewFindingImageViewModel
    
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
        let viewModel = NewFindingImageViewModel(choosenImages: FindingImageFactory.getModels())
        NewFindingImageView(viewModel: viewModel)
    }
}
