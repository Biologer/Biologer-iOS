import Foundation

final class PreviewUploadFindingsUseCase: UploadFindingsUseCase {
    private let onUpload: (UUID) throws -> Void

    init(onUpload: @escaping (UUID) throws -> Void = { _ in }) {
        self.onUpload = onUpload
    }

    func execute(
        ids: [UUID],
        onProgress: @escaping (FindingUploadProgress) async -> Void
    ) async throws {
        await onProgress(
            FindingUploadProgress(completedCount: 0, totalCount: ids.count)
        )

        for (index, id) in ids.enumerated() {
            try await Task.sleep(nanoseconds: 800_000_000)
            try onUpload(id)
            await onProgress(
                FindingUploadProgress(
                    completedCount: index + 1,
                    totalCount: ids.count
                )
            )
        }
    }
}

struct PreviewFindingSubmissionAccessUseCase: CheckFindingSubmissionAccessUseCase {
    var isAllowed = true

    func execute() -> Bool {
        isAllowed
    }
}
