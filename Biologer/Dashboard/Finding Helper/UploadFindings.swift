//
//  UploadFindings.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.11.21..
//

import Foundation

public final class UploadFindings {
    
    private let remotePostService: PostFindingService
    private let uploadImageService: PostFindingImageService
    private let dataLicenseStorage: LicenseStorage
    private let imageLicenseStorage: LicenseStorage
    private let settingsStorage: SettingsStorage
    
    public var onSuccess: Observer<Void>?
    public var onError: Observer<APIError>?
    
    init(remotePostService: PostFindingService,
         uploadImageService: PostFindingImageService,
         dataLicenseStorage: LicenseStorage,
         imageLicenseStorage: LicenseStorage,
         settingsStorage: SettingsStorage) {
        self.remotePostService = remotePostService
        self.uploadImageService = uploadImageService
        self.dataLicenseStorage = dataLicenseStorage
        self.imageLicenseStorage = imageLicenseStorage
        self.settingsStorage = settingsStorage
    }
    
    // MARK: - Public Functions
    public func upload(findings: [DBFinding],
                       projectName: String,
                       locationManager: LocationManager) {
        let findingViewModels = findings.map({
            DBFindingMapper.mapFromDB(dbFinding: $0, location: locationManager, settingsStorage: settingsStorage)
        })
        var isErrorOccured = false
        for (index, finding) in findingViewModels.enumerated() {
            if isErrorOccured {
                break
            }
            uploadImagesAndGetImagesBody(taxonImages: finding.imageViewModel.choosenImages,
                                                          onError: { [weak self] error in
                                                            isErrorOccured = true
                                                            self?.onError?((error))
                                                          }, onSuccess: { [weak self] imagesBody in
                                                            self?.upload(finding: finding,
                                                                   images: imagesBody,
                                                                   projectName: projectName,
                                                                   onSuccess: { [weak self] _ in
                                                                    if index == findings.count - 1 {
                                                                        self?.onSuccess?(())
                                                                    }
                                                                    let dbUploadedFinding = findings[index]
                                                                    finding.isUploaded = true
                                                                    
                                                                    RealmManager.update(dbUploadedFinding, block: { object in
                                                                       DBFindingMapper.mapToUpdateDB(findingViewModel: finding, dbFinding: object)
                                                                    })
                                                                   }, onError: { [weak self] error in
                                                                        isErrorOccured = true
                                                                        self?.onError?((error))
                                                                   })
                                                          })
        }
    }
    
    // MARK: - Private Functions
    private func uploadImagesAndGetImagesBody(taxonImages: [TaxonImage],
                                              onError: @escaping Observer<APIError>,
                                              onSuccess: @escaping Observer<[FindingPhotoRequestBody]>) {
        guard !taxonImages.isEmpty else {
            onSuccess(([FindingPhotoRequestBody]()))
            return
        }
        var isErrorOccured = false
        var imageNames = [String]()
        for (index, image) in taxonImages.enumerated() {
            if isErrorOccured {
                break
            }
            upload(taxonImage: image, onSuccess: { imageName in
                imageNames.append(imageName)
                if index == taxonImages.count - 1 {
                    let imageLicense = self.imageLicenseStorage.getLicense() ?? CheckMarkItemMapper.getImageLicense()[0]
                    let imagesBody = imageNames.map({
                        FindingPhotoRequestBody(license: String(imageLicense.id), path: $0)
                    })
                    onSuccess((imagesBody))
                }
            }, onError: { error in
                isErrorOccured = true
                onError((error))
            })
        }
    }
    
    
    private func upload(taxonImage: TaxonImage,
                        onSuccess: @escaping Observer<String>,
                        onError: @escaping Observer<APIError>) {
        uploadImageService.uploadFindingImages(taxonImages: taxonImage) {  result in
            switch result {
            case .failure(let error):
                print("Error upload image: \(error.localizedDescription)")
                onError((error))
            case .success(let response):
                print("Success response from upload image: \(response)")
                onSuccess(response.file ?? "")
            }
        }
    }
    
    private func upload(finding: FindingViewModel,
                        images: [FindingPhotoRequestBody]?,
                        projectName: String,
                        onSuccess: @escaping Observer<Void>,
                        onError: @escaping Observer<APIError>) {
        let dataLicense = dataLicenseStorage.getLicense() ?? CheckMarkItemMapper.getDataLicense()[0]
        let body = FindingMapper.map(finding: finding,
                                     images: images,
                                     dataLicense: dataLicense.id,
                                     projectName: projectName)
        remotePostService.uploadFinding(findingBody: body) { result in
            switch result {
                case .failure(let error):
                    print("Error uploading finding: \(error.localizedDescription)")
                    onError((error))
                case .success(_):
                    print("Uploaded successfully!!!")
                    onSuccess(())
            }
        }
    }
}
