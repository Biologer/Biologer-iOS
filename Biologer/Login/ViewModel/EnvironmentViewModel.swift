//
//  EnvironmentViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import Foundation

public final class EnvironmentViewModel: EnvironmentViewModelProtocol, Identifiable {
    public var title: String
    public var image: String
    public var url: String
    
    init(title: String, image: String, url: String) {
        self.title = title
        self.image = image
        self.url = url
    }
}
