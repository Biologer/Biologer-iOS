protocol SettingsTaxonDataUseCase {
    func hasDownloadedTaxa() -> Bool
    func resetDownloadedTaxa()
}

final class DefaultSettingsTaxonDataUseCase: SettingsTaxonDataUseCase {
    private let repository: DownloadedTaxaRepository

    init(repository: DownloadedTaxaRepository) {
        self.repository = repository
    }

    func hasDownloadedTaxa() -> Bool {
        repository.hasDownloadedTaxa()
    }

    func resetDownloadedTaxa() {
        repository.resetDownloadedTaxa()
    }
}
