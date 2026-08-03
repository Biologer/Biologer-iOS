import SwiftUI
import UIKit

struct FindingDetailsPhotoGallery: View {
    let photos: [FindingPhoto]

    var body: some View {
        FindingDetailsSection(
            title: "FindingDetailsV2.section.photos".localized,
            systemImage: "photo.on.rectangle.angled"
        ) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: BiologerSpacing.small) {
                    ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                        thumbnail(photo)
                            .accessibilityLabel(
                                "\("FindingDetailsV2.section.photos".localized) \(index + 1)"
                            )
                    }
                }
                .padding(BiologerSpacing.regular)
            }
        }
    }

    @ViewBuilder
    private func thumbnail(_ photo: FindingPhoto) -> some View {
        if
            let data = photo.imageData,
            let image = UIImage(data: data)
        {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 116, height: 92)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: BiologerRadius.control,
                        style: .continuous
                    )
                )
        } else {
            ZStack {
                RoundedRectangle(
                    cornerRadius: BiologerRadius.control,
                    style: .continuous
                )
                .fill(BiologerColors.iconBackground)

                Image(systemName: "photo")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(BiologerColors.brandStrong)
            }
            .frame(width: 116, height: 92)
        }
    }
}
