//
//  ImagesPreviewScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import Foundation

public final class ImagesPreviewScreenViewModel: ObservableObject {
    public let images: [FindingImage]
    @Published public var selectionIndex: Int
    
    init(images: [FindingImage],
         selectionIndex: Int) {
        self.images = images
        self.selectionIndex = selectionIndex
    }
}
