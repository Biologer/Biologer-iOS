//
//  TaxonRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import SwiftUI
import UIKit

public final class TaxonRouter: NSObject {
    private let navigationController: UINavigationController
    private let factory: TaxonViewControllerFactory
    private let swiftUICommonFactory: CommonViewControllerFactory
    private let uiKitCommonFactory: CommonViewControllerFactory
    private let alertFactory: AlertViewControllerFactory
    public var onSideMenuTapped: Observer<Void>?
    
    private var newTaxonScreenViewModel: NewTaxonScreenViewModel?
    private var imageCustomPickerDelegate: ImageCustomPickerDelegate?
    
    init(navigationController: UINavigationController,
         factory: TaxonViewControllerFactory,
         swiftUICommonFactory: CommonViewControllerFactory,
         uiKitCommonFactory: CommonViewControllerFactory,
         alertFactory: AlertViewControllerFactory) {
        self.navigationController = navigationController
        self.factory = factory
        self.swiftUICommonFactory = swiftUICommonFactory
        self.uiKitCommonFactory = uiKitCommonFactory
        self.alertFactory = alertFactory
    }
    
    func start() {
        showLiftOfFindingsScreen()
    }
    
    // MARK: - Private Functions
    private func showLiftOfFindingsScreen() {
        
        let vc = factory.makeListOfFindingsScreen(onNewItemTapped: { [weak self] _ in
            self?.showNewTaxonScreen()
        },
        onItemTapped: { item in
            
        })
        vc.setBiologerBackBarButtonItem(image: UIImage(named: "side_menu_icon")!,
                                        action: {
                                            self.onSideMenuTapped?(())
                                        })

        self.navigationController.setViewControllers([vc], animated: false)
    }
    
    private func showNewTaxonScreen() {
        var mapDelegate: TaxonMapScreenViewModelDelegate?
        var taxonNameDelegate: TaxonSearchScreenViewModelDelegate?
        var devStageDelegate: NewTaxonDevStageScreenViewModelDelegate?
        var nestingAtlasCodeDelegate: NestingAtlasCodeScreenViewModelDelegate?
        let vc = factory.makeNewTaxonScreen(onSaveTapped: { _ in },
                                            onLocationTapped: { [weak self] _ in
                                                self?.showTaxonMapScreen(delegate: mapDelegate)
                                            },
                                            onPhotoTapped: { [weak self] _ in
                                                self?.showPhoneImages(type: .camera)
                                            },
                                            onGalleryTapped: { [weak self] _ in
                                                self?.showPhoneImages(type: .photoLibrary)
                                            },
                                            onImageTapped: { [weak self] images, selectedImageIndex in
                                                self?.showImagesPreviewScreen(images: images,
                                                                             selectedImageIndex: selectedImageIndex)
                                            },
                                            onSearchTaxonTapped: { [weak self] _ in
                                                self?.showTaxonSearchScreen(delegate: taxonNameDelegate)
                                            },
                                            onNestingTapped: { [weak self] atlasCode in
                                                self?.showNestingAtlasCode(codes: [NestingAtlasCodeItem(name: "Species observed but supected to be on migration or to be summering non-beeder"),
                                                                                   NestingAtlasCodeItem(name: "Species observed in breeding seasson in possible naesting habitat"), NestingAtlasCodeItem(name: "Singin male(s) present (or breeding calls heard) in breeading season"), NestingAtlasCodeItem(name: "Pair observed in suitable nesting habitat in breeding season"), NestingAtlasCodeItem(name: "Permanent territory presumed through registration of teritorial behaviour (song, etc) on at last two difference days a week or more apart at the same place"), NestingAtlasCodeItem(name: "Species observed but supected to be on migration or to be summering non-beeder"), NestingAtlasCodeItem(name: "Species observed but supected to be on migration or to be summering non-beeder"),
                                                                                   NestingAtlasCodeItem(name: "Species observed in breeding seasson in possible naesting habitat"), NestingAtlasCodeItem(name: "Singin male(s) present (or breeding calls heard) in breeading season"), NestingAtlasCodeItem(name: "Pair observed in suitable nesting habitat in breeding season"), NestingAtlasCodeItem(name: "Permanent territory presumed through registration of teritorial behaviour (song, etc) on at last two difference days a week or more apart at the same place"), NestingAtlasCodeItem(name: "Species observed but supected to be on migration or to be summering non-beeder")],
                                                                           previousSelectedItem: atlasCode,
                                                                           delegate: nestingAtlasCodeDelegate)
                                            },
                                            onDevStageTapped: { [weak self] _ in
                                                self?.showDevStageScreen(stages: [DevStageViewModel(name: "Egg"), DevStageViewModel(name: "Larva"),
                                                                                  DevStageViewModel(name: "Pupa"), DevStageViewModel(name: "Adult")],
                                                                         delegate: devStageDelegate)
                                            })
        let viewController = vc as? UIHostingController<NewTaxonScreen>
        newTaxonScreenViewModel = viewController?.rootView.viewModel
        imageCustomPickerDelegate = viewController?.rootView.viewModel.imageViewModel
        mapDelegate = viewController?.rootView.viewModel
        taxonNameDelegate = viewController?.rootView.viewModel.taxonInfoViewModel
        devStageDelegate = viewController?.rootView.viewModel.taxonInfoViewModel
        nestingAtlasCodeDelegate = viewController?.rootView.viewModel.taxonInfoViewModel
        vc.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        vc.setBiologerTitle(text: "NewTaxon.lb.nav.title".localized)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func showTaxonMapScreen(delegate: TaxonMapScreenViewModelDelegate?) {
        let vc = factory.makeTaxonMapScreen(taxonLocation: TaxonLocation(latitude: 234123.234, longitute: 1234324.43))
        let viewController = vc as? UIHostingController<TaxonMapScreen>
        viewController?.rootView.viewModel.delegate = delegate
        vc.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        vc.setBiologerTitle(text: "NewTaxon.map.nav.title".localized)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func showImagesPreviewScreen(images: [TaxonImage], selectedImageIndex: Int) {
        let vc = factory.makeImagesPreivewScreen(images: images,
                                                 selectionIndex: selectedImageIndex)
        vc.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        vc.setBiologerTitle(text: "NewTaxon.image.nav.title".localized)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func showPhoneImages(type: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(type){
            imagePicker.delegate = self
            imagePicker.sourceType = type
            imagePicker.allowsEditing = false
            navigationController.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func showTaxonSearchScreen(delegate: TaxonSearchScreenViewModelDelegate?) {
        let service = DBTaxonService()
        let vc = factory.makeSearchTaxonScreen(service: service,
                                               delegate: delegate,
                                               onTaxonTapped: { [weak self] taxon in
                                                    self?.navigationController.popViewController(animated: true)
                                               },
                                               onOkTapped: { [weak self] taxon in
                                                    self?.navigationController.popViewController(animated: true)
                                               })
        vc.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        vc.setBiologerTitle(text: "NewTaxon.search.nav.title".localized)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func showDevStageScreen(stages: [DevStageViewModel],
                                    delegate: NewTaxonDevStageScreenViewModelDelegate?) {
        let vc = factory.makeDevStageScreen(stages: stages,
                                            delegate: delegate,
                                            onDone: { [weak self] _ in
                                                self?.navigationController.dismiss(animated: true, completion: nil)
                                            })
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.navigationController.present(vc, animated: true, completion: nil)
    }
    
    private func showNestingAtlasCode(codes: [NestingAtlasCodeItem],
                                      previousSelectedItem: NestingAtlasCodeItem?,
                                      delegate: NestingAtlasCodeScreenViewModelDelegate?) {
        let vc = factory.makeAtlasCodeScreen(codes: codes,
                                             previousSlectedCode: previousSelectedItem,
                                             delegate: delegate,
                                             onCodeTapped: { [weak self] _ in
                                                self?.navigationController.popViewController(animated: true)
                                             })
        vc.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        vc.setBiologerTitle(text: "NewTaxon.nestingAtlas.nav.title".localized)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    @objc func goBack() {
        navigationController.popViewController(animated: true)
    }
}

// MARK: - Taxon Rouetr Image Picker Delegate
extension TaxonRouter: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.navigationController.dismiss(animated: true, completion: nil)
        guard let choosenImage = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        imageCustomPickerDelegate?.updateImage(image: Image(uiImage: choosenImage))
    }
}
