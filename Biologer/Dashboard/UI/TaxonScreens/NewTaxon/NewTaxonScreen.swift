//
//  NewTaxonScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import SwiftUI

struct NewTaxonScreen: View {
    
    var viewModel: NewTaxonScreenViewModel
    var locationViewModel: NewTaxonLocationViewModel
    var imageViewModel: NewTaxonImageViewModel
    @ObservedObject var taxonInfoViewModel: NewTaxonInfoViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                NewTaxonSectionView(title: locationViewModel.locationTitle,
                                    content: {
                                        NewTaxonLocationView(viewModel: locationViewModel)
                                    })
                    .padding(.top, 8)

                NewTaxonSectionView(title: imageViewModel.title,
                                    content: {
                                        NewTaxonImageView(viewModel: imageViewModel)
                                    })

                NewTaxonSectionView(title: taxonInfoViewModel.title,
                                    content: {
                                        NewTaxonInfoView(viewModel: taxonInfoViewModel)
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
        
        let screenViewModel = NewTaxonScreenViewModel(onSaveTapped: { _ in })
        
        let locationViewModel = NewTaxonLocationViewModel(isLoadingLocatino: false,
                                                          latitude: "44.7732 N",
                                                          longitude: "20.4163 E",
                                                          accuraccy: "13 m",
                                                          onLocationTapped: { _ in})
        
        let imageViewModel: NewTaxonImageViewModel = NewTaxonImageViewModel(choosenImages: [TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4")],
                                                                            onFotoTapped: { _ in },
                                                                            onGalleryTapped: { _ in },
                                                                            onImageTapped: { _ in })
        
        let taxonInfoViewModel = NewTaxonInfoViewModel(observations: [Observation(name: "Call"),
                                                             Observation(name: "Exuviae")],
                                              onNestingTapped: { _ in },
                                              onDevStageTapped: { _ in })
        
        
        NewTaxonScreen(viewModel: screenViewModel,
                       locationViewModel: locationViewModel,
                       imageViewModel: imageViewModel,
                       taxonInfoViewModel: taxonInfoViewModel)
    }
}
