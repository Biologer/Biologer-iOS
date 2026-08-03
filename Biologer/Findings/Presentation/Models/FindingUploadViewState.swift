enum FindingUploadViewState: Equatable {
    case idle
    case uploading(FindingUploadProgress)
    case failure(FindingUploadProgress)

    var isUploading: Bool {
        if case .uploading = self {
            return true
        }
        return false
    }

    var progress: FindingUploadProgress? {
        switch self {
        case .uploading(let progress), .failure(let progress):
            return progress
        case .idle:
            return nil
        }
    }
}
