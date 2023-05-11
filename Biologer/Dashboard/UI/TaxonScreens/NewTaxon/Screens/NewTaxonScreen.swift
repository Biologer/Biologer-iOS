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
        ZStack {
            ScrollView {
                VStack {
                    NewTaxonSectionView(title: viewModel.findingViewModel.locationViewModel.locationTitle,
                                        content: {
                                            NewTaxonLocationView(viewModel: viewModel.findingViewModel.locationViewModel)
                                        })
                        .padding(.top, 8)

                    NewTaxonSectionView(title: viewModel.findingViewModel.imageViewModel.title,
                                        content: {
                                            NewTaxonImageView(viewModel: viewModel.findingViewModel.imageViewModel)
                                        })

                    NewTaxonSectionView(title: viewModel.findingViewModel.taxonInfoViewModel.title,
                                        content: {
                                            NewTaxonInfoView(viewModel: viewModel.findingViewModel.taxonInfoViewModel)
                                        })
                        .padding(.bottom, 120)
                    Spacer()
                }
            }
            if viewModel.findingViewModel.findingMode == .create {
                VStack {
                    Spacer()
                    VStack {
                        BiologerButton(title: viewModel.saveButtonTitle,
                                    onTapped: { _ in
                                        viewModel.saveTapped()
                                    })
                            .padding(30)
                    }
                    .frame(width: UIScreen.screenWidth, height: 100)
                    .background(Color.biologerHelpBacgroundGreen)
                    .shadow(color: Color.gray, radius: 10, x: 0, y: 0)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .animation(.default)
        .background(Color.biologerHelpBacgroundGreen)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct NewTaxonScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let locationViewModel = NewTaxonLocationViewModel(location: LocationManager())
        
        let imageViewModel: NewTaxonImageViewModel = NewTaxonImageViewModel(choosenImages: [TaxonImage(image: UIImage(named: "intro4")!), TaxonImage(image: UIImage(named:  "intro4")!), TaxonImage(image: UIImage(named: "intro4")!), TaxonImage(image: UIImage(named:  "intro4")!), TaxonImage(image: UIImage(named: "intro4")!)])
        
        let taxonInfoViewModel = NewTaxonInfoViewModel(observations: [Observation(id: 1, name: "Call"),
                                                                      Observation(id: 2, name: "Exuviae")], settingsStorage: UserDefaultsSettingsStorage())
        
        let findingViewModel = FindingViewModel(findingMode: .create,
                                                locationViewModel: locationViewModel,
                                                imageViewModel: imageViewModel,
                                                taxonInfoViewModel: taxonInfoViewModel,
                                                isUploaded: false,
                                                dateOfCreation: Date())
        
        let screenViewModel = NewTaxonScreenViewModel(findingViewModel: findingViewModel, settingsStorage: UserDefaultsSettingsStorage())
        
        NewTaxonScreen(viewModel: screenViewModel)
        

    }
}
