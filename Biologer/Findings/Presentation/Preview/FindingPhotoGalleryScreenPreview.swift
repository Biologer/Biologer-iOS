import SwiftUI
import UIKit

struct FindingPhotoGalleryScreen_Previews: PreviewProvider {
    static var previews: some View {
        FindingPhotoGalleryScreen(
            photos: [
                photo(named: "intro2"),
                photo(named: "taxon_background"),
                photo(named: "intro3")
            ],
            initialIndex: 0,
            onClose: {}
        )
        .previewDisplayName("Finding photo gallery")
    }

    private static func photo(named imageName: String) -> FindingPhoto {
        FindingPhoto(
            name: imageName,
            imageData: UIImage(named: imageName)?.pngData(),
            remoteURL: nil
        )
    }
}
