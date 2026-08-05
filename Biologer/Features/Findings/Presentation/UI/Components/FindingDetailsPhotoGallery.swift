import SwiftUI
import UIKit

struct FindingDetailsPhotoGallery: View {
    let photos: [FindingPhoto]
    let onTapPhoto: (Int) -> Void

    var body: some View {
        FindingDetailsSection(
            title: "FindingDetails.section.photos".localized,
            systemImage: "photo.on.rectangle.angled"
        ) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: BiologerSpacing.small) {
                    ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                        Button {
                            onTapPhoto(index)
                        } label: {
                            thumbnail(photo)
                        }
                        .buttonStyle(.plain)
                            .accessibilityLabel(
                                "\("FindingDetails.section.photos".localized) \(index + 1)"
                            )
                            .accessibilityHint(
                                "FindingPhotoGallery.openHint".localized
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
