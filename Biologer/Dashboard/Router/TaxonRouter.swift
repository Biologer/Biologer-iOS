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
        let vc = factory.makeNewTaxonScreen(onSaveTapped: { _ in },
                                            onLocationTapped: { _ in
                                                self.showTaxonMapScreen(delegate: mapDelegate)
                                            },
                                            onPhotoTapped: { _ in
                                                self.showPhoneImages(type: .camera)
                                            },
                                            onGalleryTapped: { _ in
                                                self.showPhoneImages(type: .photoLibrary)
                                            })
        let viewControler = vc as? UIHostingController<NewTaxonScreen>
        newTaxonScreenViewModel = viewControler?.rootView.viewModel
        mapDelegate = viewControler?.rootView.viewModel
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
    
    private func showPhoneImages(type: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(type){
            imagePicker.delegate = self
            imagePicker.sourceType = type
            imagePicker.allowsEditing = false
            navigationController.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc func goBack() {
        navigationController.popViewController(animated: true)
    }
}

// MARK: - Taxon Rouetr Image Picker Delegate
extension TaxonRouter: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController!,
                               didFinishPickingImage image: UIImage!,
                               editingInfo: NSDictionary!){
        let choosenImage = Image(uiImage: image)
        newTaxonScreenViewModel?.imageViewModel.choosenImages.append(TaxonImage(image: choosenImage))
    }
}
