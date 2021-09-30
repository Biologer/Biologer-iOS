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
                .padding(.trailing, 10)
                
            VStack(alignment: .center) {
                if !viewModel.choosenImages.isEmpty {
                        ScrollView(.horizontal) {
                            HStack(alignment: .top) {
                                ForEach(viewModel.choosenImages.indices, id: \.self) { index in
                                    Button(action: {
                                        viewModel.imageButtonTapped(selectedImageIndex: index)
                                    }, label: {
                                        viewModel.choosenImages[index].image
                                            .resizable()
                                            .cornerRadius(5)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(viewModel.isImagePlaceholder(image: viewModel.choosenImages[index].image) ? Color.white : Color.gray, lineWidth: 1)
                                            )
                                            .frame(width: 40, height: 50, alignment: .center)
                                    })
                                    .padding(.horizontal,5)
                                    .padding(.vertical, 1)
                                }
                            }
                        }
                        .padding()
                } else {
                    VStack(alignment: .center) {
                        Spacer()
                        HStack(alignment: .center) {
                            Spacer()
                            Text(viewModel.noImagesAdded)
                                .foregroundColor(Color.gray)
                                .font(.caption)
                            Spacer()
                        }
                        Spacer()
                    }
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
