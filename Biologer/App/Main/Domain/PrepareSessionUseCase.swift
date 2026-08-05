import Foundation

protocol PrepareSessionUseCase {
    func execute() async throws(SettingsDataFailure)
}

final class DefaultPrepareSessionUseCase: PrepareSessionUseCase {
    private let accountUseCase: UserAccountUseCase
    private let observationRepository: ObservationRepository
    private let userStorage: UserStorage

    init(
        accountUseCase: UserAccountUseCase,
        observationRepository: ObservationRepository,
        userStorage: UserStorage
    ) {
        self.accountUseCase = accountUseCase
        self.observationRepository = observationRepository
        self.userStorage = userStorage
    }

    func execute() async throws(SettingsDataFailure) {
        do {
            _ = try await accountUseCase.loadCurrentUser()
        } catch {
            guard userStorage.getUser() != nil else { throw error }
        }

        do {
            try await observationRepository.synchronizeObservationTypes()
        } catch {
            guard observationRepository.hasStoredObservationTypes() else { throw error }
        }
    }
}
