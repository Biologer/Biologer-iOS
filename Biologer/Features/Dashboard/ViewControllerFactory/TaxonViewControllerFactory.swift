//
//  TaxonViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import SwiftUI

public protocol TaxonViewControllerFactory {
    func makeListOfFindingsScreen(onNewItemTapped: @escaping Observer<Void>,
                                  onItemTapped: @escaping Observer<Finding>,
                                  onDeleteFindingTapped: @escaping Observer<Finding>) -> UIViewController
    func makeDeleteFindingScreen(selectedFinding: Finding,
                                 onDeleteDone: @escaping Observer<Void>) -> UIViewController
    func makeNewTaxonScreen(findingViewModel: FindingViewModel,
                            settingsStorage: SettingsStorage,
                            onSaveTapped: @escaping Observer<[FindingViewModel]>,
                            onLocationTapped: @escaping Observer<TaxonLocation?>,
                            onPhotoTapped: @escaping Observer<Void>,
                            onGalleryTapped: @escaping Observer<Void>,
                            onImageTapped: @escaping Observer<([TaxonImage], Int)>,
                            onSearchTaxonTapped: @escaping Observer<Void>,
                            onNestingTapped: @escaping Observer<NestingAtlasCodeItem?>,
                            onDevStageTapped: @escaping Observer<[DevStageViewModel]?>,
                            onFotoCountFullfiled: Observer<Void>?,
                            onFindingIsNotValid: Observer<String>?) -> UIViewController
    func makeTaxonMapScreen(locationManager: LocationManager,
                            taxonLocation: TaxonLocation?,
                            onMapTypeTapped: @escaping Observer<Void>) -> UIViewController
    func makeImagesPreivewScreen(images: [TaxonImage], selectionIndex: Int) -> UIViewController
    func makeSearchTaxonScreen(delegate: TaxonSearchScreenViewModelDelegate?,
                               settingsStorage: SettingsStorage,
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
    
    private let getAltitudeService: GetAltitudeService
    
    init(getAltitudeService: GetAltitudeService) {
        self.getAltitudeService = getAltitudeService
    }
    
    public func makeListOfFindingsScreen(onNewItemTapped: @escaping Observer<Void>,
                                         onItemTapped: @escaping Observer<Finding>,
                                         onDeleteFindingTapped: @escaping Observer<Finding>) -> UIViewController {
        let sideMenuMainViewModel = ListOfFindingsScreenViewModel(onNewItemTapped: onNewItemTapped,
                                                                  onItemTapped: onItemTapped,
                                                                  onDeleteFindingTapped: onDeleteFindingTapped)
        
        let screen = ListOfFindingsScreen(viewModel: sideMenuMainViewModel)
        let viewController = UIHostingController(rootView: screen)
        return viewController
    }
    
    public func makeDeleteFindingScreen(selectedFinding: Finding,
                                        onDeleteDone: @escaping Observer<Void>) -> UIViewController {
        let viewModel = DeleteFindingsScreenViewModel(selectedFinding: selectedFinding,
                                                      onDeleteDone: onDeleteDone)
        let screen = DeleteFindingsScreen(viewModel: viewModel)
        let controller = UIHostingController(rootView: screen)
        controller.view.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        return controller
    }
    
    public func makeNewTaxonScreen(findingViewModel: FindingViewModel,
                                   settingsStorage: SettingsStorage,
                                   onSaveTapped: @escaping Observer<[FindingViewModel]>,
                                   onLocationTapped: @escaping Observer<TaxonLocation?>,
                                   onPhotoTapped: @escaping Observer<Void>,
                                   onGalleryTapped: @escaping Observer<Void>,
                                   onImageTapped: @escaping Observer<([TaxonImage], Int)>,
                                   onSearchTaxonTapped: @escaping Observer<Void>,
                                   onNestingTapped: @escaping Observer<NestingAtlasCodeItem?>,
                                   onDevStageTapped: @escaping Observer<[DevStageViewModel]?>,
                                   onFotoCountFullfiled: Observer<Void>?,
                                   onFindingIsNotValid: Observer<String>?) -> UIViewController {
        
        findingViewModel.locationViewModel.onLocationTapped = onLocationTapped
        
        findingViewModel.imageViewModel.onFotoTapped = onPhotoTapped
        findingViewModel.imageViewModel.onGalleryTapped = onGalleryTapped
        findingViewModel.imageViewModel.onImageTapped = onImageTapped
        findingViewModel.imageViewModel.onFotoCountFullfiled = onFotoCountFullfiled
            
        findingViewModel.taxonInfoViewModel.onSearchTaxonTapped = onSearchTaxonTapped
        findingViewModel.taxonInfoViewModel.onNestingTapped = onNestingTapped
        findingViewModel.taxonInfoViewModel.onDevStageTapped = onDevStageTapped
        
        let viewModel = NewTaxonScreenViewModel(findingViewModel: findingViewModel,
                                                settingsStorage: settingsStorage)
        viewModel.onSaveTapped = onSaveTapped
        viewModel.onFindingIsNotValid = onFindingIsNotValid
        
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
        let controller = TaxonMapScreenViewController(viewModel: viewModel, getAltitudeService: getAltitudeService)
        return controller
    }
    
    public func makeImagesPreivewScreen(images: [TaxonImage], selectionIndex: Int) -> UIViewController {
        let viewModel = ImagesPreviewScreenViewModel(images: images, selectionIndex: selectionIndex)
        let screen = ImagesPreviewScreen(viewModel: viewModel)
        let controller = UIHostingController(rootView: screen)
        return controller
    }
    
    public func makeSearchTaxonScreen(delegate: TaxonSearchScreenViewModelDelegate?,
                                      settingsStorage: SettingsStorage,
                                      onTaxonTapped: @escaping Observer<TaxonViewModel>,
                                      onOkTapped: @escaping Observer<TaxonViewModel>) -> UIViewController {
        let viewModel = TaxonSearchScreenViewModel(delegate: delegate,
                                                   settingsStorage: settingsStorage,
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
