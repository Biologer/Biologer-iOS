import UIKit

public final class TaxonImage {
    let id = UUID()
    let image: UIImage
    let imageUrl: String?

    init(
        image: UIImage,
        imageUrl: String? = nil
    ) {
        self.image = image
        self.imageUrl = imageUrl
    }
}
