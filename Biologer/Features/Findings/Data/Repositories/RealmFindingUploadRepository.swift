import Foundation
import ImageIO
import RealmSwift
import UniformTypeIdentifiers

private enum RealmFindingUploadRepositoryError: Error {
    case invalidImageData
}

final class RealmFindingUploadRepository: FindingUploadRepository {
    private let configuration: Realm.Configuration
    private let remoteRepository: FindingRemoteUploadRepository
    private let dataLicenseStorage: LicenseStorage
    private let imageLicenseStorage: LicenseStorage
    private let settingsStorage: SettingsStorage

    init(
        configuration: Realm.Configuration,
        remoteRepository: FindingRemoteUploadRepository,
        dataLicenseStorage: LicenseStorage,
        imageLicenseStorage: LicenseStorage,
        settingsStorage: SettingsStorage
    ) {
        self.configuration = configuration
        self.remoteRepository = remoteRepository
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
            guard let uploadData = Self.makeJPEGData(from: imageData) else {
                throw RealmFindingUploadRepositoryError.invalidImageData
            }

            let path = try await remoteRepository.uploadImage(uploadData)
            photos.append(
                FindingPhotoRequestBody(
                    license: String(imageLicenseID),
                    path: path
                )
            )
        }

        return photos
    }

    private static func makeJPEGData(from imageData: Data) -> Data? {
        guard
            let source = CGImageSourceCreateWithData(imageData as CFData, nil),
            let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else {
            return nil
        }

        let encodedData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            encodedData,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            return nil
        }

        CGImageDestinationAddImage(
            destination,
            image,
            [kCGImageDestinationLossyCompressionQuality: 0.7] as CFDictionary
        )
        guard CGImageDestinationFinalize(destination) else { return nil }
        return encodedData as Data
    }

    private func uploadFinding(_ request: FindingRequestBody) async throws {
        try await remoteRepository.uploadFinding(request)
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
