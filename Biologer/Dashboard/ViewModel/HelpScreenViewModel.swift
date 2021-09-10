//
//  HelpScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import Foundation

public struct HelpItemViewModel: Hashable, Identifiable {
    public let id = UUID()
    var title: String
    var description: String
    var image: String
}

public final class HelpItemManager {
    static func createHelpItems() -> [HelpItemViewModel] {
        return [HelpItemViewModel(title: "Database option",
                                  description: "Biologer application can connected to multiple datebase. You should start by choosing your preferred datebase and registering online.",
                                  image: "intro1"),
                HelpItemViewModel(title: "Navigation is easy",
                                          description: "Side panel provides all the shortcuts and settings you need. Just swipe screen to the right and you are ready to go.",
                                          image: "intro2"),
                HelpItemViewModel(title: "Tha main screen",
                                          description: "From the main screen you can add, edit or delete your observation and send data to one of our service.",
                                          image: "intro3"),
                HelpItemViewModel(title: "New observations",
                                          description: "Adding data is easy! Suggest the species, add some photos and Biologer do the rest. Advance optios can also be unlocked from the Preferences.",
                                          image: "intro4"),]
    }
}

public final class HelpScreenViewModel: HelpScreenLoader, ObservableObject {
    var items: [HelpItemViewModel] = HelpItemManager.createHelpItems()
    var title: String = "Database option"
    var description: String = "Biologer application can connected to multiple datebase. You should start by choosing your preferred datebase and registering online."
    var numerOfPages: Int = 5
    @Published var currentPageIndex: Int = 0
    
    private let onDone: Observer<Void>
    
    init(onDone: @escaping Observer<Void>) {
        self.onDone = onDone
    }
    
    func nextTapped() {
        if currentPageIndex < 3 {
            currentPageIndex += 1
        }
    }
    
    func previousTapped() {
        if currentPageIndex > 0 {
            currentPageIndex -= 1
        }
    }
}
