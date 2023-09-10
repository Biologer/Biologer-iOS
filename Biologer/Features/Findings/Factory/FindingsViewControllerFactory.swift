//
//  FindingsViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import SwiftUI

public protocol FindingsViewControllerFactory {
    func makeListOfFindingsScreen(onNewItemTapped: @escaping Observer<Void>,
                                  onItemTapped: @escaping Observer<Finding>,
                                  onDeleteFindingTapped: @escaping Observer<Finding>) -> UIViewController
    func makeDeleteFindingScreen(selectedFinding: Finding,
                                 onDeleteDone: @escaping Observer<Void>) -> UIViewController
    func makeNewFindingScreen(findingViewModel: FindingViewModel,
                              settingsStorage: SettingsStorage,
                              onSaveTapped: @escaping Observer<[FindingViewModel]>,
                              onLocationTapped: @escaping Observer<FindingLocation?>,
                              onPhotoTapped: @escaping Observer<Void>,
                              onGalleryTapped: @escaping Observer<Void>,
                              onImageTapped: @escaping Observer<([FindingImage], Int)>,
                              onSearchTaxonTapped: @escaping Observer<Void>,
                              onNestingTapped: @escaping Observer<NestingAtlasCodeItem?>,
                              onDevStageTapped: @escaping Observer<[DevStageViewModel]?>,
                              onFotoCountFullfiled: Observer<Void>?,
                              onFindingIsNotValid: Observer<String>?) -> UIViewController
    func makeFindingMapScreen(locationManager: LocationManager,
                              taxonLocation: FindingLocation?,
                              onMapTypeTapped: @escaping Observer<Void>) -> UIViewController
    func makeImagesPreivewScreen(images: [FindingImage], selectionIndex: Int) -> UIViewController
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

public final class SwiftUIFindingsViewControllerFactory: FindingsViewControllerFactory {
    
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
    
    public func makeNewFindingScreen(findingViewModel: FindingViewModel,
                                     settingsStorage: SettingsStorage,
                                     onSaveTapped: @escaping Observer<[FindingViewModel]>,
                                     onLocationTapped: @escaping Observer<FindingLocation?>,
                                     onPhotoTapped: @escaping Observer<Void>,
                                     onGalleryTapped: @escaping Observer<Void>,
                                     onImageTapped: @escaping Observer<([FindingImage], Int)>,
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
        
        let viewModel = NewFindingScreenViewModel(findingViewModel: findingViewModel,
                                                settingsStorage: settingsStorage)
        viewModel.onSaveTapped = onSaveTapped
        viewModel.onFindingIsNotValid = onFindingIsNotValid
        
        let screen = NewFindingScreen(viewModel: viewModel)
        let controller = UIHostingController(rootView: screen)
        return controller
    }
    
    public func makeFindingMapScreen(locationManager: LocationManager,
                                     taxonLocation: FindingLocation? = nil,
                                     onMapTypeTapped: @escaping Observer<Void>) -> UIViewController {
        let viewModel = TaxonMapScreenViewModel(locationManager: locationManager,
                                                taxonLocation: taxonLocation,
                                                onMapTypeTapped: onMapTypeTapped)
        let controller = FindingMapScreenViewController(viewModel: viewModel, getAltitudeService: getAltitudeService)
        return controller
    }
    
    public func makeImagesPreivewScreen(images: [FindingImage], selectionIndex: Int) -> UIViewController {
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
        let viewModel = NewFindingDevStageScreenViewModel(stages: stages,
                                                        delegate: delegate,
                                                        onDone: onDone)
        let screen = NewFindingDevStageScreen(viewModel: viewModel)
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
