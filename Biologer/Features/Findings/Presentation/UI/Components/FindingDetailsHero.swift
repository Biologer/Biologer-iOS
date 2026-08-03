import SwiftUI
import UIKit

struct FindingDetailsHero: View {
    let details: FindingDetails
    let onTapPhoto: () -> Void

    var body: some View {
        Button(action: onTapPhoto) {
            ZStack(alignment: .bottomLeading) {
                heroImage

                LinearGradient(
                    colors: [.clear, .black.opacity(0.72)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                Text(displayedTaxonName)
                    .font(.title2.weight(.bold))
                    .italic()
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .padding(BiologerSpacing.large)
            }
        }
        .buttonStyle(.plain)
        .disabled(details.photos.isEmpty)
        .frame(height: 238)
        .clipShape(
            RoundedRectangle(
                cornerRadius: BiologerRadius.hero,
                style: .continuous
            )
        )
        .overlay(alignment: .topTrailing) {
            uploadStatusBadge
                .padding(BiologerSpacing.small)
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: BiologerRadius.hero,
                style: .continuous
            )
            .stroke(.white.opacity(0.12), lineWidth: 1)
        }
        .shadow(
            color: BiologerColors.brandStrong.opacity(0.2),
            radius: 12,
            y: 6
        )
        .accessibilityElement(children: .combine)
        .accessibilityHint(
            details.photos.isEmpty
                ? ""
                : "FindingPhotoGallery.openHint".localized
        )
    }

    @ViewBuilder
    private var heroImage: some View {
        if
            let data = details.photos.first?.imageData,
            let image = UIImage(data: data)
        {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        } else {
            ZStack {
                LinearGradient(
                    colors: [
                        BiologerColors.brandStrong,
                        BiologerColors.accent
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: "leaf.fill")
                    .font(.system(size: 76, weight: .semibold))
                    .foregroundColor(.white.opacity(0.22))
            }
        }
    }

    private var uploadStatusBadge: some View {
        let isUploaded = details.uploadStatus == .uploaded

        return HStack(spacing: BiologerSpacing.xxSmall) {
            Image(
                systemName: isUploaded
                    ? "checkmark.circle.fill"
                    : "icloud.and.arrow.up"
            )

            Text(
                isUploaded
                    ? "ListOfFindingsV2.status.uploaded".localized
                    : "ListOfFindingsV2.status.pending".localized
            )
        }
        .font(.caption.weight(.semibold))
        .foregroundColor(isUploaded ? BiologerColors.brandStrong : .orange)
        .padding(.horizontal, BiologerSpacing.small)
        .padding(.vertical, BiologerSpacing.xSmall)
        .background(.white.opacity(0.94), in: Capsule())
    }

    private var displayedTaxonName: String {
        details.taxonName.isEmpty ? "-" : details.taxonName
    }
}
