import Combine
import Foundation

enum FindingDetailsV2LoadState: Equatable {
    case idle
    case loading
    case content
    case failure
}

@MainActor
final class FindingDetailsV2ViewModel: ObservableObject {
    @Published private(set) var details: FindingDetails?
    @Published private(set) var loadState: FindingDetailsV2LoadState = .idle
    @Published private(set) var uploadState: FindingUploadViewState = .idle

    private let findingID: UUID
    private let getFindingDetails: GetFindingDetailsUseCase
    private let uploadFindings: UploadFindingsUseCase
    private let onEditFinding: (UUID) -> Void
    private let onShowLocation: (FindingDetailsLocation) -> Void
    private let onShowPhotos: ([FindingPhoto], Int) -> Void
    private var uploadTask: Task<Void, Never>?

    init(
        findingID: UUID,
        getFindingDetails: GetFindingDetailsUseCase,
        uploadFindings: UploadFindingsUseCase,
        onEditFinding: @escaping (UUID) -> Void,
        onShowLocation: @escaping (FindingDetailsLocation) -> Void,
        onShowPhotos: @escaping ([FindingPhoto], Int) -> Void
    ) {
        self.findingID = findingID
        self.getFindingDetails = getFindingDetails
        self.uploadFindings = uploadFindings
        self.onEditFinding = onEditFinding
        self.onShowLocation = onShowLocation
        self.onShowPhotos = onShowPhotos
    }

    var isUploading: Bool {
        uploadState.isUploading
    }

    var hasUploadError: Bool {
        if case .failure = uploadState {
            return true
        }
        return false
    }

    func loadDetails() {
        guard !isUploading else { return }
        loadState = .loading

        do {
            details = try getFindingDetails.execute(id: findingID)
            loadState = .content
        } catch {
            details = nil
            loadState = .failure
        }
    }

    func didTapEdit() {
        guard !isUploading else { return }
        onEditFinding(findingID)
    }

    func didTapShowLocation() {
        guard !isUploading, let location = details?.location else { return }
        onShowLocation(location)
    }

    func didTapPhoto(at index: Int) {
        guard
            !isUploading,
            let photos = details?.photos,
            photos.indices.contains(index)
        else {
            return
        }

        onShowPhotos(photos, index)
    }

    func didTapUpload() {
        guard details?.uploadStatus == .pending, !isUploading else { return }

        let initialProgress = FindingUploadProgress(
            completedCount: 0,
            totalCount: 1
        )
        uploadState = .uploading(initialProgress)
        uploadTask?.cancel()
        uploadTask = Task { [weak self] in
            guard let self else { return }

            do {
                try await uploadFindings.execute(ids: [findingID]) { [weak self] progress in
                    await MainActor.run {
                        self?.uploadState = .uploading(progress)
                    }
                }
                uploadState = .idle
                loadDetails()
            } catch is CancellationError {
                uploadState = .idle
            } catch {
                uploadState = .failure(
                    uploadState.progress ?? initialProgress
                )
            }
        }
    }

    func dismissUploadError() {
        uploadState = .idle
    }
}
