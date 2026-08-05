import SwiftUI
import UIKit

struct FindingEditorPhotoSection: View {
    let photos: [FindingEditorPhoto]
    let onCamera: () -> Void
    let onLibrary: () -> Void
    let onOpen: (Int) -> Void
    let onDelete: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: BiologerSpacing.small) {
            HStack(spacing: BiologerSpacing.small) {
                addButton(
                    title: "FindingEditor.photo.camera".localized,
                    systemImage: "camera.fill",
                    action: onCamera
                )
                addButton(
                    title: "FindingEditor.photo.library".localized,
                    systemImage: "photo.on.rectangle.angled",
                    action: onLibrary
                )
            }

            if photos.isEmpty {
                HStack(spacing: BiologerSpacing.small) {
                    Image(systemName: "photo.badge.plus")
                        .font(.title2)
                        .foregroundColor(BiologerColors.accent)

                    Text("FindingEditor.photo.empty".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 76)
                .background(
                    BiologerColors.pageBackground,
                    in: RoundedRectangle(
                        cornerRadius: BiologerRadius.control,
                        style: .continuous
                    )
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: BiologerSpacing.small) {
                        ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                            thumbnail(photo, index: index)
                        }
                    }
                }
            }

            Text("FindingEditor.photo.limit".localized)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func addButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: BiologerSpacing.xxSmall) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, BiologerSpacing.small)
        }
        .buttonStyle(.plain)
        .foregroundColor(BiologerColors.accent)
        .background(BiologerColors.iconBackground, in: RoundedRectangle(cornerRadius: BiologerRadius.control))
    }

    private func thumbnail(_ photo: FindingEditorPhoto, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Button {
                onOpen(index)
            } label: {
                photoContent(photo)
                    .frame(width: 124, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: BiologerRadius.control))
            }
            .buttonStyle(.plain)

            Button {
                onDelete(photo.id)
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white)
                    .frame(width: 26, height: 26)
                    .background(.black.opacity(0.66), in: Circle())
            }
            .buttonStyle(.plain)
            .padding(BiologerSpacing.xSmall)
        }
    }

    @ViewBuilder
    private func photoContent(_ photo: FindingEditorPhoto) -> some View {
        if let data = photo.imageData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else if let remoteURL = photo.remoteURL {
            AsyncImage(url: remoteURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                photoPlaceholder
            }
        } else {
            photoPlaceholder
        }
    }

    private var photoPlaceholder: some View {
        ZStack {
            BiologerColors.iconBackground
            Image(systemName: "photo")
                .font(.title2)
                .foregroundColor(BiologerColors.brandStrong)
        }
    }
}
