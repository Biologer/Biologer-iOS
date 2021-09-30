//
//  TaxonViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import SwiftUI

public protocol TaxonViewControllerFactory {
    func makeListOfFindingsScreen(onNewItemTapped: @escaping Observer<Void>,
                                  onItemTapped: @escaping Observer<Item>) -> UIViewController
    func makeNewTaxonScreen(onSaveTapped: @escaping Observer<Void>) -> UIViewController
}

public final class SwiftUITaxonViewControllerFactory: TaxonViewControllerFactory {
    public func makeListOfFindingsScreen(onNewItemTapped: @escaping Observer<Void>,
                                  onItemTapped: @escaping Observer<Item>) -> UIViewController {
        let sideMenuMainViewModel = ListOfFindingsScreenViewModel(onNewItemTapped: onNewItemTapped,
                                                                  onItemTapped: onItemTapped)
        
        let screen = ListOfFindingsScreen(loader: sideMenuMainViewModel)
        let viewController = UIHostingController(rootView: screen)
        return viewController
    }
    
    public func makeNewTaxonScreen(onSaveTapped: @escaping Observer<Void>) -> UIViewController {
        let viewModel = NewTaxonScreenViewModel(onSaveTapped: onSaveTapped)
        
        let locationViewModel = NewTaxonLocationViewModel(isLoadingLocatino: false,
                                                          latitude: "44.7732 N",
                                                          longitude: "20.4163 E",
                                                          accuraccy: "13 m",
                                                          onLocationTapped: { _ in})
        
        let imageViewModel = NewTaxonImageViewModel(choosenImages: [TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"),],
                                               onFotoTapped: { _ in },
                                               onGalleryTapped: { _ in },
                                               onImageTapped: { _ in })
        
        let taxonInfoViewModel = NewTaxonInfoViewModel(observations: [Observation(name: "NewTaxon.btn.callObservation.text".localized),
                                                                      Observation(name: "NewTaxon.btn.exuviaeObservation.text".localized)],
                                              onNestingTapped: { _ in },
                                              onDevStageTapped: { _ in })
        
        let screen = NewTaxonScreen(viewModel: viewModel,
                                    locationViewModel: locationViewModel,
                                    imageViewModel: imageViewModel,
                                    taxonInfoViewModel: taxonInfoViewModel)
        let controller = UIHostingController(rootView: screen)
        return controller
    }
}
