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
    func makeNewTaxonScreen(onButtonTapped: @escaping Observer<Void>) -> UIViewController
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
    
    public func makeNewTaxonScreen(onButtonTapped: @escaping Observer<Void>) -> UIViewController {
        let viewModel = NewTaxonScreenViewModel(onButtonTapped: onButtonTapped)
        
        let locationViewModel = NewTaxonLocationViewModel(isLoadingLocatino: false,
                                                          latitude: "44.7732 N",
                                                          longitude: "20.4163 E",
                                                          accuraccy: "13 m",
                                                          onLocationTapped: { _ in})
        
        let imageViewModel = NewTaxonImageViewModel(choosenImages: [TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"), TaxonImage(name: "intro4"),],
                                               onFotoTapped: { _ in },
                                               onGalleryTapped: { _ in },
                                               onImageTapped: { _ in })
        
        let taxonInfoViewModel = NewTaxonInfoViewModel(observations: [Observation(name: "Call"),
                                                             Observation(name: "Exuviae")],
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
