//
//  Item.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.6.21..
//

import UIKit

public class Finding {
    let id: UUID
    let taxon: String
    let image: UIImage?
    let developmentStage: String
    let isUploaded: Bool
    
    var getFindingImage: UIImage {
        return image ?? UIImage(named: "gallery_icon")!
    }
    
    init(id: UUID,
         taxon: String,
         image: UIImage?,
         developmentStage: String,
         isUploaded: Bool) {
        self.id = id
        self.taxon = taxon
        self.image = image
        self.developmentStage = developmentStage
        self.isUploaded = isUploaded
    }
}
