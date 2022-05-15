//
//  NewTaxonImageViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 28.9.21..
//

import SwiftUI

public final class TaxonImage {
    let id = UUID()
    let image: UIImage
    let imageUrl: String?
    
    init(image: UIImage,
         imageUrl: String? = nil) {
        self.image = image
        self.imageUrl = imageUrl
    }
}

protocol ImageCustomPickerDelegate {
    func updateImage(taxonImage: TaxonImage)
}

public final class NewTaxonImageViewModel: ObservableObject {
    public let title: String = "NewTaxon.lb.image.title".localized
    public let fotoButtonImage: String = "foto_icon"
    public let galleryButtonImage: String = "gallery_icon"
    public let noImagesAdded: String = "NewTaxon.image.placeholder.title".localized
    @Published public private(set) var choosenImages = [TaxonImage]()
    public var onFotoTapped: Observer<Void>?
    public var onGalleryTapped: Observer<Void>?
    public var onFotoCountFullfiled: Observer<Void>?
    public var onImageTapped: Observer<([TaxonImage], Int)>?
    
    private let maxImageCount = 3
    
    init(choosenImages: [TaxonImage]) {
        self.choosenImages = choosenImages
    }
    
    public func fotoButtonTapped() {
        if choosenImages.count < maxImageCount {
            onFotoTapped?(())
        } else {
            onFotoCountFullfiled?(())
        }
    }
    
    public func gallerButtonTapped() {
        if choosenImages.count < maxImageCount {
            onGalleryTapped?(())
        } else {
            onFotoCountFullfiled?(())
        }
    }
    
    public func imageButtonTapped(selectedImageIndex: Int) {
        onImageTapped?((choosenImages, selectedImageIndex))
    }
    
    public func delteImage(at index: Int) {
        choosenImages.remove(at: index)
    }
    
    public func isImagePlaceholder(image: Image) -> Bool {
        return image == Image("img_placeholder_icon")
    }
}

extension NewTaxonImageViewModel: ImageCustomPickerDelegate {
    func updateImage(taxonImage: TaxonImage) {
        choosenImages.append(taxonImage)
        choosenImages.reverse()
    }
}


