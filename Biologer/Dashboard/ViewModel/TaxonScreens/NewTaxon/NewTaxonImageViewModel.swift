//
//  NewTaxonImageViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 28.9.21..
//

import Foundation

public final class TaxonImage {
    let id = UUID()
    let name: String
    
    init(name: String) {
        self.name = name
    }
}

public final class NewTaxonImageViewModel: ObservableObject {
    public let title: String = "NewTaxon.lb.image.title".localized
    public let fotoButtonImage: String = "foto_icon"
    public let galleryButtonImage: String = "gallery_icon"
    @Published public var choosenImages = [TaxonImage]()
    private let onFotoTapped: Observer<Void>
    private let onGalleryTapped: Observer<Void>
    private let onImageTapped: Observer<String>
    
    init(choosenImages: [TaxonImage],
         onFotoTapped: @escaping Observer<Void>,
         onGalleryTapped: @escaping Observer<Void>,
         onImageTapped: @escaping Observer<String>) {
        self.choosenImages = choosenImages
        self.onFotoTapped = onFotoTapped
        self.onGalleryTapped = onGalleryTapped
        self.onImageTapped = onImageTapped
    }
    
    public func fotoButtonTapped() {
        onFotoTapped(())
        choosenImages.append(TaxonImage(name: "intro2"))
    }
    
    public func gallerButtonTapped() {
        choosenImages.removeLast()
        onGalleryTapped(())
    }
    
    public func imageButtonTapped(selectedImage: String) {
        onImageTapped((selectedImage))
    }
}
