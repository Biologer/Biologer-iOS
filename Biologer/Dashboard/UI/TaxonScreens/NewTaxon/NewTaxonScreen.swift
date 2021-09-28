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
    
    var body: some View {
        ScrollView {
            VStack {
                NewTaxonSectionView(title: locationViewModel.locationTitle,
                                    content: {
                                        NewTaxonLocationView(viewModel: locationViewModel)
                                    })
                
                NewTaxonSectionView(title: imageViewModel.title,
                                    content: {
                                        NewTaxonImageView(viewModel: imageViewModel)
                                    })
                Spacer()
            }
        }
    }
}

struct NewTaxonScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let screenViewModel = NewTaxonScreenViewModel(onButtonTapped: { _ in })
        
        let locationViewModel = NewTaxonLocationViewModel(isLoadingLocatino: false,
                                                          latitude: "44.7732 N",
                                                          longitude: "20.4163 E",
                                                          accuraccy: "13 m",
                                                          onLocationTapped: { _ in})
        
        let imageViewModel: NewTaxonImageViewModel = NewTaxonImageViewModel(choosenImages: [TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4")],
                                                                            onFotoTapped: { _ in },
                                                                            onGalleryTapped: { _ in },
                                                                            onImageTapped: { _ in })
        
        
        NewTaxonScreen(viewModel: screenViewModel,
                       locationViewModel: locationViewModel,
                       imageViewModel: imageViewModel)
    }
}
