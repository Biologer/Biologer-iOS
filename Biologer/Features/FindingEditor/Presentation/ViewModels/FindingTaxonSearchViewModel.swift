import Combine
import Foundation

enum FindingTaxonSearchState: Equatable {
    case idle
    case loading
    case results
    case empty
    case failure
}

@MainActor
final class FindingTaxonSearchViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var results: [FindingEditorTaxon] = []
    @Published private(set) var state: FindingTaxonSearchState = .idle

    private let searchTaxa: SearchFindingTaxaUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        searchTaxa: SearchFindingTaxaUseCase
    ) {
        self.searchTaxa = searchTaxa

        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.search(query)
            }
            .store(in: &cancellables)
    }

    var normalizedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canUseCustomName: Bool {
        normalizedQuery.count >= 2
    }

    func customTaxon() -> FindingEditorTaxon? {
        guard canUseCustomName else { return nil }
        return FindingEditorTaxon(
            apiID: nil,
            name: normalizedQuery,
            usesAtlasCodes: false,
            developmentStages: [],
            translations: []
        )
    }

    func retry() {
        search(query)
    }

    private func search(_ query: String) {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalizedQuery.count >= 2 else {
            results = []
            state = .idle
            return
        }

        state = .loading
        do {
            results = try searchTaxa.execute(query: normalizedQuery)
            state = results.isEmpty ? .empty : .results
        } catch {
            results = []
            state = .failure
        }
    }
}
