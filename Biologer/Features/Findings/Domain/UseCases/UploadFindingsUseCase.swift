import Foundation

struct FindingUploadProgress: Equatable {
    let completedCount: Int
    let totalCount: Int

    var fractionCompleted: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
}

protocol UploadFindingsUseCase {
    func execute(
        ids: [UUID],
        onProgress: @escaping (FindingUploadProgress) async -> Void
    ) async throws
}

final class DefaultUploadFindingsUseCase: UploadFindingsUseCase {
    private let repository: FindingUploadRepository

    init(repository: FindingUploadRepository) {
        self.repository = repository
    }

    func execute(
        ids: [UUID],
        onProgress: @escaping (FindingUploadProgress) async -> Void
    ) async throws {
        let initialProgress = FindingUploadProgress(
            completedCount: 0,
            totalCount: ids.count
        )
        await onProgress(initialProgress)

        for (index, id) in ids.enumerated() {
            try Task.checkCancellation()
            try await repository.upload(id: id)
            await onProgress(
                FindingUploadProgress(
                    completedCount: index + 1,
                    totalCount: ids.count
                )
            )
        }
    }
}
