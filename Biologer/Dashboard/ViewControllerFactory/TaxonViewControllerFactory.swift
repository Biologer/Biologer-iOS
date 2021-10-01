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
    func makeNewTaxonScreen(onSaveTapped: @escaping Observer<Void>,
                            onLocationTapped: @escaping Observer<Void>,
                            onPhotoTapped: @escaping Observer<Void>,
                            onGalleryTapped: @escaping Observer<Void>,
                            onImageTapped: @escaping Observer<([TaxonImage], Int)>,
                            onSearchTaxonTapped: @escaping Observer<Void>) -> UIViewController
    func makeTaxonMapScreen(taxonLocation: TaxonLocation?) -> UIViewController
    func makeImagesPreivewScreen(images: [TaxonImage], selectionIndex: Int) -> UIViewController
    func makeSearchTaxonScreen(service: TaxonService,
                               delegate: TaxonSearchScreenViewModelDelegate?,
                               onTaxonTapped: @escaping Observer<TaxonViewModel>,
                               onOkTapped: @escaping Observer<TaxonViewModel>) -> UIViewController
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
    
    public func makeNewTaxonScreen(onSaveTapped: @escaping Observer<Void>,
                                   onLocationTapped: @escaping Observer<Void>,
                                   onPhotoTapped: @escaping Observer<Void>,
                                   onGalleryTapped: @escaping Observer<Void>,
                                   onImageTapped: @escaping Observer<([TaxonImage], Int)>,
                                   onSearchTaxonTapped: @escaping Observer<Void>) -> UIViewController {
        
        let locationViewModel = NewTaxonLocationViewModel(isLoadingLocatino: false,
                                                          latitude: "44.7732 N",
                                                          longitude: "20.4163 E",
                                                          accuraccy: "13 m",
                                                          onLocationTapped: onLocationTapped)
        
        let imageViewModel = NewTaxonImageViewModel(choosenImages: [],
                                                    onFotoTapped: onPhotoTapped,
                                                    onGalleryTapped: onGalleryTapped,
                                                    onImageTapped: onImageTapped)
        
        let taxonInfoViewModel = NewTaxonInfoViewModel(observations: [Observation(name: "NewTaxon.btn.callObservation.text".localized),
                                                                      Observation(name: "NewTaxon.btn.exuviaeObservation.text".localized)],
                                                       onSearchTaxonTapped: onSearchTaxonTapped,
                                                       onNestingTapped: { _ in },
                                                       onDevStageTapped: { _ in })
        
        let viewModel = NewTaxonScreenViewModel(locationViewModel: locationViewModel,
                                                imageViewModel: imageViewModel,
                                                taxonInfoViewModel: taxonInfoViewModel,
                                                onSaveTapped: onSaveTapped)
        
        let screen = NewTaxonScreen(viewModel: viewModel)
        let controller = UIHostingController(rootView: screen)
        return controller
    }
    
    public func makeTaxonMapScreen(taxonLocation: TaxonLocation?) -> UIViewController {
        let viewModel = TaxonMapScreenViewModel(location: taxonLocation)
        let screen = TaxonMapScreen(viewModel: viewModel)
        let controller = UIHostingController(rootView: screen)
        return controller
    }
    
    public func makeImagesPreivewScreen(images: [TaxonImage], selectionIndex: Int) -> UIViewController {
        let viewModel = ImagesPreviewScreenViewModel(images: images, selectionIndex: selectionIndex)
        let screen = ImagesPreviewScreen(viewModel: viewModel)
        let controller = UIHostingController(rootView: screen)
        return controller
    }
    
    public func makeSearchTaxonScreen(service: TaxonService,
                                      delegate: TaxonSearchScreenViewModelDelegate?,
                                      onTaxonTapped: @escaping Observer<TaxonViewModel>,
                                      onOkTapped: @escaping Observer<TaxonViewModel>) -> UIViewController {
        let viewModel = TaxonSearchScreenViewModel(service: service,
                                                   delegate: delegate,
                                                   onTaxonTapped: onTaxonTapped,
                                                   onOkTapped: onOkTapped)
        let screen = TaxonSearchScreen(viewModel: viewModel)
        let controller = UIHostingController(rootView: screen)
        return controller
    }
}
