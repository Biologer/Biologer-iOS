import Foundation

public struct HelpItemViewModel: Hashable, Identifiable {
    public let id = UUID()
    var title: String
    var description: String
    var image: String
}

@MainActor
public final class HelpScreenViewModel: ObservableObject {
    var items: [HelpItemViewModel] = HelpItemManager.createHelpItems()
    @Published var currentPageIndex: Int = 0

    @discardableResult
    func nextTapped() -> Bool {
        if currentPageIndex < items.count - 1 {
            currentPageIndex += 1
            return false
        } else {
            return true
        }
    }

    func previousTapped() {
        if currentPageIndex > 0 {
            currentPageIndex -= 1
        }
    }
}
