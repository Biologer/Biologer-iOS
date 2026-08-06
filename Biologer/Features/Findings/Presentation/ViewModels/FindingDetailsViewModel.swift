import Combine
import Foundation

enum FindingDetailsLoadState: Equatable {
    case idle
    case loading
    case content
    case failure
}

@MainActor
final class FindingDetailsViewModel: ObservableObject {
    @Published private(set) var details: FindingDetails?
    @Published private(set) var loadState: FindingDetailsLoadState = .idle
    @Published private(set) var uploadState: FindingUploadViewState = .idle
    @Published private(set) var showsSubmissionWarning = false

    private let findingID: UUID
    private let useCases: FindingDetailsUseCases
    private var uploadTask: Task<Void, Never>?

    init(
        findingID: UUID,
        useCases: FindingDetailsUseCases
    ) {
        self.findingID = findingID
        self.useCases = useCases
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
            details = try useCases.getFindingDetails.execute(id: findingID)
            loadState = .content
        } catch {
            details = nil
            loadState = .failure
        }
    }

    func editableFindingID() -> UUID? {
        isUploading ? nil : findingID
    }

    func selectedLocation() -> FindingDetailsLocation? {
        guard !isUploading else { return nil }
        return details?.location
    }

    func photoPresentation(at index: Int) -> ([FindingPhoto], Int)? {
        guard
            !isUploading,
            let photos = details?.photos,
            photos.indices.contains(index)
        else {
            return nil
        }
        return (photos, index)
    }

    func didTapUpload() {
        guard details?.uploadStatus == .pending, !isUploading else { return }
        guard useCases.checkSubmissionAccess.execute() else {
            showsSubmissionWarning = true
            return
        }

        let initialProgress = FindingUploadProgress(
            completedCount: 0,
            totalCount: 1
        )
        uploadState = .uploading(initialProgress)
        uploadTask?.cancel()
        uploadTask = Task { [weak self] in
            guard let self else { return }

            do {
                try await useCases.uploadFindings.execute(ids: [findingID]) { [weak self] progress in
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

    func dismissSubmissionWarning() {
        showsSubmissionWarning = false
    }
}
