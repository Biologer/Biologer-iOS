import Foundation
import RealmSwift
import UIKit

private enum RealmFindingUploadRepositoryError: Error {
    case invalidImageData
}

final class RealmFindingUploadRepository: FindingUploadRepository {
    private let configuration: Realm.Configuration
    private let remotePostService: PostFindingService
    private let uploadImageService: PostFindingImageService
    private let dataLicenseStorage: LicenseStorage
    private let imageLicenseStorage: LicenseStorage
    private let settingsStorage: SettingsStorage

    init(
        configuration: Realm.Configuration,
        remotePostService: PostFindingService,
        uploadImageService: PostFindingImageService,
        dataLicenseStorage: LicenseStorage,
        imageLicenseStorage: LicenseStorage,
        settingsStorage: SettingsStorage
    ) {
        self.configuration = configuration
        self.remotePostService = remotePostService
        self.uploadImageService = uploadImageService
        self.dataLicenseStorage = dataLicenseStorage
        self.imageLicenseStorage = imageLicenseStorage
        self.settingsStorage = settingsStorage
    }

    func upload(id: UUID) async throws {
        let snapshots = try makeSnapshots(id: id)
        let imageLicenseID = imageLicenseStorage.getLicense()?.id
            ?? CheckMarkItemMapper.getImageLicense().first?.id
            ?? 10
        let dataLicenseID = dataLicenseStorage.getLicense()?.id
            ?? CheckMarkItemMapper.getDataLicense().first?.id
            ?? 10
        let projectName = settingsStorage.getSettings()?.projectName ?? ""

        for snapshot in snapshots {
            try Task.checkCancellation()
            let photos = try await uploadImages(
                snapshot.imageData,
                imageLicenseID: imageLicenseID
            )
            let request = FindingUploadRequestMapper.makeRequest(
                from: snapshot,
                photos: photos,
                dataLicenseID: dataLicenseID,
                projectName: projectName
            )

            try await uploadFinding(request)
            try markComponentAsUploaded(
                findingID: snapshot.id,
                component: snapshot.component
            )
        }

        try markAsUploaded(id: id)
    }

    private func makeSnapshots(id: UUID) throws -> [FindingUploadSnapshot] {
        let realm = try Realm(configuration: configuration)
        guard let finding = realm.object(
            ofType: DBFinding.self,
            forPrimaryKey: id
        ) else {
            throw FindingsRepositoryError.findingNotFound(id)
        }

        let observationTypeIDs = Array(
            realm.objects(DBObservation.self).map(\.id)
        )
        return FindingUploadRequestMapper.makeSnapshots(
            from: finding,
            availableObservationTypeIDs: observationTypeIDs
        )
    }

    private func uploadImages(
        _ images: [Data],
        imageLicenseID: Int
    ) async throws -> [FindingPhotoRequestBody] {
        var photos: [FindingPhotoRequestBody] = []

        for imageData in images {
            try Task.checkCancellation()
            guard let image = UIImage(data: imageData) else {
                throw RealmFindingUploadRepositoryError.invalidImageData
            }

            let path = try await uploadImage(TaxonImage(image: image))
            photos.append(
                FindingPhotoRequestBody(
                    license: String(imageLicenseID),
                    path: path
                )
            )
        }

        return photos
    }

    private func uploadImage(_ image: TaxonImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            uploadImageService.uploadFindingImages(taxonImages: image) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response.file ?? "")
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func uploadFinding(_ request: FindingRequestBody) async throws {
        try await withCheckedThrowingContinuation { continuation in
            remotePostService.uploadFinding(findingBody: request) { result in
                switch result {
                case .success:
                    continuation.resume(returning: ())
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func markAsUploaded(id: UUID) throws {
        let realm = try Realm(configuration: configuration)
        guard let finding = realm.object(
            ofType: DBFinding.self,
            forPrimaryKey: id
        ) else {
            throw FindingsRepositoryError.findingNotFound(id)
        }

        try realm.write {
            finding.isUploaded = true
        }
    }

    private func markComponentAsUploaded(
        findingID: UUID,
        component: FindingUploadComponent
    ) throws {
        guard component != .fallback else { return }

        let realm = try Realm(configuration: configuration)
        guard let finding = realm.object(
            ofType: DBFinding.self,
            forPrimaryKey: findingID
        ) else {
            throw FindingsRepositoryError.findingNotFound(findingID)
        }

        let individual: DBFindingIndividual?
        switch component {
        case .male:
            individual = finding.individuals?.male
        case .female:
            individual = finding.individuals?.female
        case .total:
            individual = finding.individuals?.all
        case .fallback:
            individual = nil
        }

        guard let individual else { return }
        try realm.write {
            individual.isUploaded = true
        }
    }
}
