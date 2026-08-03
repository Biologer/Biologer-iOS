import Foundation

public final class HelpItemManager {
    static func createHelpItems() -> [HelpItemViewModel] {
        [
            HelpItemViewModel(
                title: "Help.title.first".localized,
                description: "Help.desc.first".localized,
                image: "intro1"
            ),
            HelpItemViewModel(
                title: "Help.title.second".localized,
                description: "Help.desc.second".localized,
                image: "intro2"
            ),
            HelpItemViewModel(
                title: "Help.title.third".localized,
                description: "Help.desc.third".localized,
                image: "intro3"
            ),
            HelpItemViewModel(
                title: "Help.title.fourth".localized,
                description: "Help.desc.fourth".localized,
                image: "intro4"
            )
        ]
    }
}
