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
    func makeNewTaxonScreen(location: LocationManager,
                            onSaveTapped: @escaping Observer<Void>,
                            onLocationTapped: @escaping Observer<TaxonLocation?>,
                            onPhotoTapped: @escaping Observer<Void>,
                            onGalleryTapped: @escaping Observer<Void>,
                            onImageTapped: @escaping Observer<([TaxonImage], Int)>,
                            onSearchTaxonTapped: @escaping Observer<Void>,
                            onNestingTapped: @escaping Observer<NestingAtlasCodeItem?>,
                            onDevStageTapped: @escaping Observer<Void>) -> UIViewController
    func makeTaxonMapScreen(locationManager: LocationManager,
                            taxonLocation: TaxonLocation?,
                            onMapTypeTapped: @escaping Observer<Void>) -> UIViewController
    func makeImagesPreivewScreen(images: [TaxonImage], selectionIndex: Int) -> UIViewController
    func makeSearchTaxonScreen(service: TaxonService,
                               delegate: TaxonSearchScreenViewModelDelegate?,
                               onTaxonTapped: @escaping Observer<TaxonViewModel>,
                               onOkTapped: @escaping Observer<TaxonViewModel>) -> UIViewController
    func makeDevStageScreen(stages: [DevStageViewModel],
                            delegate: NewTaxonDevStageScreenViewModelDelegate?,
                            onDone: @escaping Observer<Void>) -> UIViewController
    func makeAtlasCodeScreen(codes: [NestingAtlasCodeItem],
                             previousSlectedCode: NestingAtlasCodeItem?,
                             delegate: NestingAtlasCodeScreenViewModelDelegate?,
                             onCodeTapped: @escaping Observer<Void>) -> UIViewController
    func makeMapTypeScreen(delegate: MapTypeScreenViewModelDelegate?,
                           onTypeTapped: @escaping Observer<MapTypeViewModel>) -> UIViewController
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
    
    public func makeNewTaxonScreen(location: LocationManager,
                                   onSaveTapped: @escaping Observer<Void>,
                                   onLocationTapped: @escaping Observer<TaxonLocation?>,
                                   onPhotoTapped: @escaping Observer<Void>,
                                   onGalleryTapped: @escaping Observer<Void>,
                                   onImageTapped: @escaping Observer<([TaxonImage], Int)>,
                                   onSearchTaxonTapped: @escaping Observer<Void>,
                                   onNestingTapped: @escaping Observer<NestingAtlasCodeItem?>,
                                   onDevStageTapped: @escaping Observer<Void>) -> UIViewController {
        
        let locationViewModel = NewTaxonLocationViewModel(location: location,
                                                          onLocationTapped: onLocationTapped)
        
        let imageViewModel = NewTaxonImageViewModel(choosenImages: [],
                                                    onFotoTapped: onPhotoTapped,
                                                    onGalleryTapped: onGalleryTapped,
                                                    onImageTapped: onImageTapped)
        
        let taxonInfoViewModel = NewTaxonInfoViewModel(observations: [Observation(name: "NewTaxon.btn.callObservation.text".localized),
                                                                      Observation(name: "NewTaxon.btn.exuviaeObservation.text".localized)],
                                                       onSearchTaxonTapped: onSearchTaxonTapped,
                                                       onNestingTapped: onNestingTapped,
                                                       onDevStageTapped: onDevStageTapped)
        
        let viewModel = NewTaxonScreenViewModel(locationViewModel: locationViewModel,
                                                imageViewModel: imageViewModel,
                                                taxonInfoViewModel: taxonInfoViewModel,
                                                onSaveTapped: onSaveTapped)
        
        let screen = NewTaxonScreen(viewModel: viewModel)
        let controller = UIHostingController(rootView: screen)
        return controller
    }
    
    public func makeTaxonMapScreen(locationManager: LocationManager,
                                   taxonLocation: TaxonLocation? = nil,
                                   onMapTypeTapped: @escaping Observer<Void>) -> UIViewController {
        let viewModel = TaxonMapScreenViewModel(locationManager: locationManager,
                                                taxonLocation: taxonLocation,
                                                onMapTypeTapped: onMapTypeTapped)
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
    
    public func makeDevStageScreen(stages: [DevStageViewModel],
                            delegate: NewTaxonDevStageScreenViewModelDelegate?,
                            onDone: @escaping Observer<Void>) -> UIViewController {
        let viewModel = NewTaxonDevStageScreenViewModel(stages: stages,
                                                        delegate: delegate,
                                                        onDone: onDone)
        let screen = NewTaxonDevStageScreen(viewModel: viewModel)
        let controller = UIHostingController(rootView: screen)
        controller.view.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        return controller
    }
    
    public func makeAtlasCodeScreen(codes: [NestingAtlasCodeItem],
                             previousSlectedCode: NestingAtlasCodeItem?,
                             delegate: NestingAtlasCodeScreenViewModelDelegate?,
                             onCodeTapped: @escaping Observer<Void>) -> UIViewController {
        let viewModel = NestingAtlasCodeScreenViewModel(codes: codes,
                                                        previousSlectedCode: previousSlectedCode,
                                                        delegate: delegate,
                                                        onCodeTapped: onCodeTapped)
        let screen = NestingAtlasCodeScreen(viewModel: viewModel)
        let controller = UIHostingController(rootView: screen)
        return controller
    }
    
    public func makeMapTypeScreen(delegate: MapTypeScreenViewModelDelegate?,
                                  onTypeTapped: @escaping Observer<MapTypeViewModel>) -> UIViewController {
        let viewModel = MapTypeScreenViewModel(delegate: delegate,
                                               onTypeTapped: onTypeTapped)
        let screen = MapTypeScreen(viewModel: viewModel)
        let controller = UIHostingController(rootView: screen)
        controller.view.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        return controller
    }
}
