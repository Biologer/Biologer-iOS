//
//  FindingsRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import SwiftUI
import UIKit

public final class FindingsRouter: NSObject {
    private let navigationController: UINavigationController
    private let factory: FindingsViewControllerFactory
    private let commonFactory: CommonViewControllerFactory
    private let alertFactory: AlertViewControllerFactory
    private let location: LocationManager
    private let uploadFindings: UploadFindings
    private let taxonServiceManager: TaxonServiceManager
    private let taxonPaginationInfoStorage: TaxonsPaginationInfoStorage
    private let settingsStorage: SettingsStorage
    private let userStorage: UserStorage
    private var biologerProgressBarDelegate: BiologerProgressBarDelegate?
    private var onLoadingDone: (() -> Void)?
    public var onSideMenuTapped: Observer<Void>?
    
    private var newTaxonScreenViewModel: NewFindingScreenViewModel?
    private var imageCustomPickerDelegate: ImageCustomPickerDelegate?
    private var listOfFindingsViewController: UIViewController?
    
    init(navigationController: UINavigationController,
         location: LocationManager,
         taxonServiceManager: TaxonServiceManager,
         taxonPaginationInfoStorage: TaxonsPaginationInfoStorage,
         settingsStorage: SettingsStorage,
         uploadFindings: UploadFindings,
         factory: FindingsViewControllerFactory,
         commonFactory: CommonViewControllerFactory,
         alertFactory: AlertViewControllerFactory,
         userStorage: UserStorage) {
        self.navigationController = navigationController
        self.location = location
        self.uploadFindings = uploadFindings
        self.taxonServiceManager = taxonServiceManager
        self.taxonPaginationInfoStorage = taxonPaginationInfoStorage
        self.settingsStorage = settingsStorage
        self.factory = factory
        self.commonFactory = commonFactory
        self.alertFactory = alertFactory
        self.userStorage = userStorage
    }
    
    lazy var onLoading: Observer<Bool> = { [weak self] isLoading in
        guard let self = self else { return }
        if isLoading {
            let loader  = self.commonFactory.createBlockingProgress()
            self.navigationController.hardPresent(loader, animated: false, completion: nil)
        } else {
            self.navigationController.dismiss(animated: false, completion: nil)
        }
    }
    
    func start() {
        showLiftOfFindingsScreen()
    }
    
    // MARK: - Private Functions
    private func showLiftOfFindingsScreen() {
        var deleteFindingDelegate: DeleteFindingsScreenViewModelDelegate?
        let vc = factory.makeListOfFindingsScreen(onNewItemTapped: { [weak self] _ in
            guard let self = self else { return }
            if let user = self.userStorage.getUser(), !user.isVerified {
                self.showUnverifiedUser(onDissmis: { [weak self] in
                    guard let self = self else { return }
                    self.location.startUpdateingLocation()
                    self.showNewTaxonScreen(findingViewModel: self.makeDefaultFidingViewModel())
                })
            } else {
                self.location.startUpdateingLocation()
                self.showNewTaxonScreen(findingViewModel: self.makeDefaultFidingViewModel())
            }
        },
                                                  onItemTapped: { [weak self] item in
            guard let self = self else { return }
            if let dbFinding = RealmManager.get(fromEntity: DBFinding.self, primaryKey: item.id) {
                self.showNewTaxonScreen(findingViewModel: DBFindingMapper.mapFromDB(dbFinding: dbFinding,
                                                                                    location: self.location,
                                                                                    settingsStorage: self.settingsStorage))
            } else {
                print("Can't find finding in Data Base")
            }
        },
                                                  onDeleteFindingTapped: { [weak self] finding in
            self?.showDeleteFindingsScreen(selectedFinding: finding,
                                           delegate: deleteFindingDelegate)
        })
        vc.setBiologerBackBarButtonItem(image: UIImage(named: "side_menu_icon")!,
                                        action: {
            self.onSideMenuTapped?(())
        })
        vc.setBiologerRightButtonItem(image: UIImage(named: "upload_icon")!,
                                      action: {
            self.uploadFindingFlow()
        })
        
        let viewController = vc as? UIHostingController<ListOfFindingsScreen>
        deleteFindingDelegate = viewController?.rootView.viewModel
        listOfFindingsViewController = vc
        vc.setBiologerTitle(text: "ListOfFindings.nav.title".localized)
        self.navigationController.setViewControllers([vc], animated: false)
    }
    
    private func showDeleteFindingsScreen(selectedFinding: Finding,
                                          delegate: DeleteFindingsScreenViewModelDelegate?) {
        let vc = factory.makeDeleteFindingScreen(selectedFinding: selectedFinding,
                                                 onDeleteDone: { _ in
            self.navigationController.dismiss(animated: true, completion: nil)
        })
        let viewController = vc as? UIHostingController<DeleteFindingsScreen>
        viewController?.rootView.viewModel.delegate = delegate
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.navigationController.present(vc, animated: true, completion: nil)
    }
    
    private func showNewTaxonScreen(findingViewModel: FindingViewModel) {
        var mapDelegate: TaxonMapScreenViewModelDelegate?
        var taxonNameDelegate: TaxonSearchScreenViewModelDelegate?
        var devStageDelegate: NewTaxonDevStageScreenViewModelDelegate?
        var nestingAtlasCodeDelegate: NestingAtlasCodeScreenViewModelDelegate?
        let vc = factory.makeNewFindingScreen(findingViewModel: findingViewModel,
                                              settingsStorage: settingsStorage,
                                              onSaveTapped: { [weak self] findings in
            self?.addOrUpdateFindingsToDb(findings: findings)
            self?.location.stopUpdatingLocation()
            self?.navigationController.popViewController(animated: true)
        },
                                              onLocationTapped: { [weak self] taxonLocation in
            self?.showTaxonMapScreen(delegate: mapDelegate,
                                     taxonLocation: taxonLocation)
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
            self?.showNestingAtlasCode(codes: NestingAtlasCodeMapper.getNestingCodes(),
                                       previousSelectedItem: atlasCode,
                                       delegate: nestingAtlasCodeDelegate)
        },
                                              onDevStageTapped: { [weak self] stages in
            if let stages = stages, !stages.isEmpty {
                self?.showDevStageScreen(stages: stages,
                                         delegate: devStageDelegate)
            }
        },
                                              onFotoCountFullfiled: { _ in
            self.showConfirmationAlert(popUpType: .info,
                                       title: "NewTaxon.image.errorPopUp.title".localized,
                                       description: "NewTaxon.image.errorPopUp.description".localized)
        }, onFindingIsNotValid: { errorText in
            self.showConfirmationAlert(popUpType: .error,
                                       title: "API.lb.error".localized,
                                       description: errorText)
        })
        let viewController = vc as? UIHostingController<NewFindingScreen>
        newTaxonScreenViewModel = viewController?.rootView.viewModel
        imageCustomPickerDelegate = viewController?.rootView.viewModel.findingViewModel.imageViewModel
        mapDelegate = viewController?.rootView.viewModel.findingViewModel.locationViewModel
        taxonNameDelegate = viewController?.rootView.viewModel.findingViewModel.taxonInfoViewModel
        devStageDelegate = viewController?.rootView.viewModel.findingViewModel.taxonInfoViewModel
        nestingAtlasCodeDelegate = viewController?.rootView.viewModel.findingViewModel.taxonInfoViewModel
        vc.setBiologerBackBarButtonItem {
            self.location.stopUpdatingLocation()
            self.goBack()
        }
        vc.setBiologerTitle(text: "NewTaxon.lb.nav.title".localized)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func showTaxonMapScreen(delegate: TaxonMapScreenViewModelDelegate?,
                                    taxonLocation: FindingLocation?) {
        var mapTypeDelegate: MapTypeScreenViewModelDelegate?
        let vc = factory.makeFindingMapScreen(locationManager: location,
                                              taxonLocation: taxonLocation,
                                              onMapTypeTapped: { [weak self] _ in
            self?.showMapTypeScreen(delegate: mapTypeDelegate)
        })
        self.location.stopUpdatingLocation()
        let viewController = vc as? TaxonMapScreenViewController
        viewController?.viewModel.delegate = delegate
        mapTypeDelegate = viewController?.viewModel
        vc.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        vc.setBiologerTitle(text: "NewTaxon.map.nav.title".localized)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func showImagesPreviewScreen(images: [FindingImage], selectedImageIndex: Int) {
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
        let vc = factory.makeSearchTaxonScreen(delegate: delegate,
                                               settingsStorage: settingsStorage,
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
    
    private func showMapTypeScreen(delegate: MapTypeScreenViewModelDelegate?) {
        let vc = factory.makeMapTypeScreen(delegate: delegate,
                                           onTypeTapped: { [weak self] _ in
            self?.navigationController.dismiss(animated: true, completion: nil)
        })
        let viewController = vc as? UIHostingController<MapTypeScreen>
        viewController?.rootView.viewModel.delegate = delegate
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.navigationController.present(vc, animated: true, completion: nil)
    }
    
    private func showBilogerProgressBarScreen(maxValue: Double,
                                              currentValue: Double = 0.0,
                                              onProgressAppeared: @escaping Observer<Double>,
                                              onCancelTapped: @escaping Observer<Double>) {
        let vc = commonFactory.makeBiologerProgressBarView(maxValue: maxValue,
                                                           currentValue: currentValue,
                                                           onProgressAppeared: onProgressAppeared,
                                                           onCancelTapped: onCancelTapped)
        let viewController = vc as? UIHostingController<BiologerProgressBarScreen>
        biologerProgressBarDelegate = viewController?.rootView.viewModel
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.navigationController.present(vc, animated: true, completion: nil)
    }
    
    private func showDownloadTaxonsProgressBar() {
        var maxValue: Double = 10
        var currentValue: Double = 0
        if let paginationInfo = taxonPaginationInfoStorage.getPaginationInfo() {
            maxValue = Double(paginationInfo.lastPage)
            currentValue = Double(paginationInfo.currentPage)
        }
        showBilogerProgressBarScreen(maxValue: maxValue,
                                     currentValue: currentValue,
                                     onProgressAppeared: { [weak self] currentValue in
            
            self?.taxonServiceManager.resumeGetTaxon()
            self?.taxonServiceManager.getTaxons { currentValue, maxValue in
                self?.biologerProgressBarDelegate?.updateProgressBar(currentValue: currentValue, maxValue: maxValue)
                if currentValue == maxValue {
                    self?.navigationController.dismiss(animated: true, completion: nil)
                }
            }
        },
                                     onCancelTapped: { [weak self] currentValue in
            self?.taxonServiceManager.stopGetTaxon()
            self?.navigationController.dismiss(animated: true, completion: nil)
        })
    }
    
    private func showConfirmationAlert(popUpType: PopUpType,
                                       title: String,
                                       description: String) {
        let vc = alertFactory.makeConfirmationAlert(popUpType: popUpType,
                                                    title: title,
                                                    description: description,
                                                    onTapp: { _ in
            self.navigationController.dismiss(animated: true, completion: nil)
        })
        self.navigationController.present(vc, animated: true, completion: nil)
    }
    
    private func showYesOrNoAlert(title: String,
                                  onYesTapped: @escaping Observer<Void>,
                                  onNoTapped: @escaping Observer<Void>) {
        let vc = alertFactory.makeYesAndNoAlert(title: title, onYesTapped: onYesTapped, onNoTapped: onNoTapped)
        self.navigationController.present(vc, animated: true, completion: nil)
    }
    
    @objc func goBack() {
        navigationController.popViewController(animated: true)
    }
    
    private func makeDefaultFidingViewModel() -> FindingViewModel {
        let locationViewModel = NewFindingLocationViewModel(location: location)
        let imageViewModel = NewFindingImageViewModel(choosenImages: [])
        let dbObservations = RealmManager.get(fromEntity: DBObservation.self)
        var observations = [Observation]()
        dbObservations.forEach({ observations.append(Observation(id: $0.id, name: $0.translation.first!.name))})
        let taxonInfoViewModel = NewFindingInfoViewModel(observations: observations,
                                                       settingsStorage: settingsStorage)
        let findingViewModel = FindingViewModel(findingMode: .create,
                                                locationViewModel: locationViewModel,
                                                imageViewModel: imageViewModel,
                                                taxonInfoViewModel: taxonInfoViewModel,
                                                isUploaded: false,
                                                dateOfCreation: Date())
        return findingViewModel
    }
    
    private func addOrUpdateFindingsToDb(findings: [FindingViewModel]) {
        for finding in findings {
            if finding.findingMode == .create {
                let dbFinding = DBFindingMapper.mapToDB(findingViewModel: finding)
                RealmManager.add(dbFinding)
            } else {
                if let getFinding = RealmManager.get(fromEntity: DBFinding.self, primaryKey: finding.id ?? UUID()) {
                    RealmManager.update(getFinding, block: { object in
                        DBFindingMapper.mapToUpdateDB(findingViewModel: finding, dbFinding: object)
                    })
                }
            }
        }
    }
    
    private func showOrDissmisLoader(shouldPresent: Bool, onDissmis: (() -> Void)? = nil) {
        if shouldPresent {
            let loader  = self.commonFactory.createBlockingProgress()
            self.navigationController.hardPresent(loader, animated: false, completion: nil)
        } else {
            self.navigationController.dismiss(animated: false, completion: onDissmis)
        }
    }
    
    private func showUnverifiedUser(onDissmis: @escaping Observer<Void>) {
        let confirmAlert = self.alertFactory.makeConfirmationAlert(popUpType: .warning,
                                                                   title: "Common.title.warning".localized,
                                                                   description: "ListOfFindings.popUpUserVerified.description".localized,
                                                                   onTapp: { [weak self] in
            self?.navigationController.dismiss(animated: true,
                                               completion: {
                onDissmis(())
            })
        })
        self.navigationController.present(confirmAlert, animated: true, completion: nil)
    }
    
    // MARK: - Upload Findings flow
    private func uploadFindingFlow() {
        guard let user = userStorage.getUser(), user.isVerified else {
            showUnverifiedUser(onDissmis: { _ in })
            return
        }
        let findings = RealmManager.get(fromEntity: DBFinding.self)
        var findingsToUpload = [DBFinding]()
        findings.forEach({
            if !$0.isUploaded {
                findingsToUpload.append($0)
            }
        })
        if findingsToUpload.isEmpty {
            self.showConfirmationAlert(popUpType: .info,
                                       title: "UploadFindings.noFindingsToUploadPopUp.title".localized,
                                       description: "UploadFindings.noFindingsToUploadPopUp.description".localized)
        } else {
            uploadFindings(findingsToUpload: findingsToUpload)
        }
    }
    
    private func uploadFindings(findingsToUpload: [DBFinding]) {
        let checkInternetConnection = CheckInternetConnection.init()
        if !checkInternetConnection.isConnectedToInternet() {
            showConfirmationAlert(popUpType: .error,
                                  title: "API.lb.error".localized,
                                  description: "Common.title.notConnectedToInternet".localized)
        } else if !checkInternetConnection.isConnectedToWiFi() {
            internetErrorOnUploadingFindings(title: "Common.title.notConnectedToWiFi".localized,
                                             findingsToUpload: findingsToUpload)
        } else {
            showUploadFindingPopUp(findingsToUpload: findingsToUpload, onYesTapped: { [weak self] _ in
                self?.startUploadingFindings(findingsToUpload: findingsToUpload)
            })
        }
    }
    
    private func internetErrorOnUploadingFindings(title: String, findingsToUpload: [DBFinding]) {
        showYesOrNoAlert(title: title,
                         onYesTapped: { [weak self] _ in
            self?.navigationController.dismiss(animated: true, completion: {
                self?.startUploadingFindings(findingsToUpload: findingsToUpload)
            })
        }, onNoTapped: { [weak self] _ in
            self?.navigationController.dismiss(animated: true, completion: nil)
        })
    }
    
    private func startUploadingFindings(findingsToUpload: [DBFinding]) {
        self.showOrDissmisLoader(shouldPresent: true, onDissmis: nil)
        self.uploadFindings.upload(findings: findingsToUpload,
                                   projectName: self.settingsStorage.getSettings()?.projectName ?? "",
                                   locationManager: self.location)
        self.uploadFindings.onError = { error in
            self.showOrDissmisLoader(shouldPresent: false, onDissmis: {
                self.showConfirmationAlert(popUpType: .error,
                                           title: error.title,
                                           description: error.description)
            })
        }
        
        self.uploadFindings.onSuccess = { _ in
            self.showOrDissmisLoader(shouldPresent: false, onDissmis: {
                self.showConfirmationAlert(popUpType: .success,
                                           title: "UploadFindings.uploadedFindingPopUp.title".localized,
                                           description: "UploadFindings.uploadedFindingPopUp.description".localized)
                self.reloadListOfFindings()
            })
        }
    }
    
    private func reloadListOfFindings() {
        if let vc = listOfFindingsViewController {
            let viewController = vc as? UIHostingController<ListOfFindingsScreen>
            let viewModel = viewController?.rootView.viewModel
            viewModel?.getData()
        }
    }
    
    private func showUploadFindingPopUp(findingsToUpload: [DBFinding],
                                        onYesTapped: @escaping Observer<Void>) {
        self.showYesOrNoAlert(title: "UploadFindings.yesOrNoPopUp.title".localized,
                              onYesTapped: { [weak self] _ in
            guard let self = self else { return }
            self.navigationController.dismiss(animated: true, completion: {
                onYesTapped(())
            })
        }, onNoTapped: { [weak self] _ in
            self?.navigationController.dismiss(animated: true, completion: nil)
        })
    }
}

// MARK: - Taxon Rouetr Image Picker Delegate
extension FindingsRouter: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.navigationController.dismiss(animated: true, completion: nil)
        guard let choosenImage = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        var imageName = ""
        if let fileUrl = info[.imageURL] as? URL {
            imageName = fileUrl.lastPathComponent
        } else {
            imageName = createImageNameWithDate()
        }
        print("Image name: \(imageName)")
        
        imageCustomPickerDelegate?.updateImage(taxonImage: FindingImage(image: choosenImage, imageUrl: imageName))
    }
    
    private func createImageNameWithDate() -> String {
        var imageName = ""
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'_'HH_mm_ss"
        
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        
        imageName = "\(dateFormatter.string(from: date)).jpg"
        return imageName
    }
}

