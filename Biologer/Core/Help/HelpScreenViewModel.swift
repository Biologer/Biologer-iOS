import Foundation

public struct HelpItemViewModel: Hashable, Identifiable {
    public let id = UUID()
    var title: String
    var description: String
    var image: String
}

public final class HelpScreenViewModel: ObservableObject {
    var items: [HelpItemViewModel] = HelpItemManager.createHelpItems()
    @Published var currentPageIndex: Int = 0

    private let onDone: Observer<Void>

    init(onDone: @escaping Observer<Void>) {
        self.onDone = onDone
    }

    func nextTapped() {
        if currentPageIndex < items.count - 1 {
            currentPageIndex += 1
        } else {
            onDone(())
        }
    }

    func previousTapped() {
        if currentPageIndex > 0 {
            currentPageIndex -= 1
        }
    }
}
