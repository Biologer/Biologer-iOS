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
        VStack {
            HStack {
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
                Spacer()
            }
            .padding(.bottom, 10)
            
            if !viewModel.choosenImages.isEmpty {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.choosenImages, id: \.id) { item in
                            Button(action: {
                                viewModel.imageButtonTapped(selectedImage: item.name)
                            }, label: {
                                Image(item.name)
                                    .resizable()
                                    .frame(width: 40, height: 50, alignment: .center)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                            })
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
    }
}

struct NewTaxonImageView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = NewTaxonImageViewModel(choosenImages: [TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"),TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"),TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"),TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4")],
                                               onFotoTapped: { _ in },
                                               onGalleryTapped: { _ in },
                                               onImageTapped: { _ in })
        NewTaxonImageView(viewModel: viewModel)
    }
}
