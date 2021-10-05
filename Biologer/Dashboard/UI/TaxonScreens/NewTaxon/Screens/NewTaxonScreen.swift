//
//  NewTaxonScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import SwiftUI

struct NewTaxonScreen: View {
    
    @ObservedObject var viewModel: NewTaxonScreenViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                NewTaxonSectionView(title: viewModel.locationViewModel.locationTitle,
                                    content: {
                                        NewTaxonLocationView(viewModel: viewModel.locationViewModel)
                                    })
                    .padding(.top, 8)

                NewTaxonSectionView(title: viewModel.imageViewModel.title,
                                    content: {
                                        NewTaxonImageView(viewModel: viewModel.imageViewModel)
                                    })

                NewTaxonSectionView(title: viewModel.taxonInfoViewModel.title,
                                    content: {
                                        NewTaxonInfoView(viewModel: viewModel.taxonInfoViewModel)
                                    })
                    .padding(.bottom, 20)
                BiologerButton(title: viewModel.saveButtonTitle,
                            onTapped: { _ in
                                viewModel.saveTapped()
                            })
                    .padding(.bottom, 30)
                Spacer()
            }
        }
        .animation(.default)
        .background(Color.biologerGreenColor.opacity(0.4))
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct NewTaxonScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let locationViewModel = NewTaxonLocationViewModel(location: LocationManager(),
                                                          onLocationTapped: { _ in})
        
        let imageViewModel: NewTaxonImageViewModel = NewTaxonImageViewModel(choosenImages: [TaxonImage(image: Image("intro4")), TaxonImage(image: Image("intro4")), TaxonImage(image: Image("intro4")), TaxonImage(image: Image("intro4")), TaxonImage(image: Image("intro4"))],
                                                                            onFotoTapped: { _ in },
                                                                            onGalleryTapped: { _ in },
                                                                            onImageTapped: { _ in })
        
        let taxonInfoViewModel = NewTaxonInfoViewModel(observations: [Observation(name: "Call"),
                                                                      Observation(name: "Exuviae")], onSearchTaxonTapped: { _ in },
                                              onNestingTapped: { _ in },
                                              onDevStageTapped: { _ in })
        
        let screenViewModel = NewTaxonScreenViewModel(locationViewModel: locationViewModel,
                                                      imageViewModel: imageViewModel,
                                                      taxonInfoViewModel: taxonInfoViewModel,
                                                      onSaveTapped: { _ in })
        
        NewTaxonScreen(viewModel: screenViewModel)
    }
}
