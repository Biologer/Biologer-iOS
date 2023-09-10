//
//  NewFindingScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import SwiftUI

struct NewFindingScreen: View {
    
    @ObservedObject var viewModel: NewFindingScreenViewModel
    
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
                                            NewFindingImageView(viewModel: viewModel.findingViewModel.imageViewModel)
                                        })

                    NewTaxonSectionView(title: viewModel.findingViewModel.taxonInfoViewModel.title,
                                        content: {
                                            NewFindingInfoView(viewModel: viewModel.findingViewModel.taxonInfoViewModel)
                                        })
                        .padding(.bottom, 120)
                    Spacer()
                }
            }
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
            .ignoresSafeArea(.keyboard)
        }
        .navigationBarBackButtonHidden(true)
        .animation(.default)
        .background(Color.biologerHelpBacgroundGreen)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct NewTaxonScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let locationViewModel = NewFindingLocationViewModel(location: LocationManager())
        
        let imageViewModel: NewFindingImageViewModel = NewFindingImageViewModel(choosenImages: FindingImageFactory.getModels())
        
        let taxonInfoViewModel = NewFindingInfoViewModel(observations: [Observation(id: 1, name: "Call"),
                                                                      Observation(id: 2, name: "Exuviae")], settingsStorage: UserDefaultsSettingsStorage())
        
        let findingViewModel = FindingViewModel(findingMode: .create,
                                                locationViewModel: locationViewModel,
                                                imageViewModel: imageViewModel,
                                                taxonInfoViewModel: taxonInfoViewModel,
                                                isUploaded: false,
                                                dateOfCreation: Date())
        
        let screenViewModel = NewFindingScreenViewModel(findingViewModel: findingViewModel, settingsStorage: UserDefaultsSettingsStorage())
        
        NewFindingScreen(viewModel: screenViewModel)
        

    }
}
