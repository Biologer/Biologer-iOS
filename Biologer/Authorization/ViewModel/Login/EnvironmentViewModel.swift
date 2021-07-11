//
//  EnvironmentViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import Foundation

public final class EnvironmentViewModel: EnvironmentViewModelProtocol, Identifiable, ObservableObject {
    @Published public var title: String
    @Published public var image: String
    @Published public var url: String
    @Published public var isSelected: Bool
    
    init(title: String, image: String, url: String, isSelected: Bool) {
        self.title = title
        self.image = image
        self.url = url
        self.isSelected = isSelected
    }
}
