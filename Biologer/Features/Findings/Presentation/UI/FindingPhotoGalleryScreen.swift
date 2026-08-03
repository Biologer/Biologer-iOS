import SwiftUI
import UIKit

struct FindingPhotoGalleryScreen: View {
    let photos: [FindingPhoto]
    let onClose: () -> Void

    @State private var selectedIndex: Int

    init(
        photos: [FindingPhoto],
        initialIndex: Int,
        onClose: @escaping () -> Void
    ) {
        self.photos = photos
        self.onClose = onClose
        let lastIndex = max(photos.count - 1, 0)
        _selectedIndex = State(
            initialValue: min(max(initialIndex, 0), lastIndex)
        )
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.ignoresSafeArea()
                photoPager

                VStack(spacing: 0) {
                    topControls
                    Spacer()
                    zoomHint
                }
                .padding(.top, max(proxy.safeAreaInsets.top, 12))
                .padding(.bottom, max(proxy.safeAreaInsets.bottom, 12))
                .padding(.horizontal, BiologerSpacing.regular)
            }
        }
        .statusBarHidden(true)
    }

    @ViewBuilder
    private var photoPager: some View {
        if photos.isEmpty {
            unavailablePhoto
        } else {
            TabView(selection: $selectedIndex) {
                ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                    photoPage(photo, index: index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }

    private var topControls: some View {
        HStack {
            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.body.weight(.bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("FindingPhotoGallery.close".localized)
        }
        .overlay {
            if !photos.isEmpty {
                Text(pageCounter)
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, BiologerSpacing.small)
                    .padding(.vertical, BiologerSpacing.xSmall)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }

    private var zoomHint: some View {
        HStack(spacing: BiologerSpacing.xSmall) {
            Image(systemName: "magnifyingglass")
            Text("FindingPhotoGallery.zoomHint".localized)
        }
        .font(.caption.weight(.medium))
        .foregroundColor(.white.opacity(0.92))
        .padding(.horizontal, BiologerSpacing.small)
        .padding(.vertical, BiologerSpacing.xSmall)
        .background(.ultraThinMaterial, in: Capsule())
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func photoPage(_ photo: FindingPhoto, index: Int) -> some View {
        if
            let imageData = photo.imageData,
            let image = UIImage(data: imageData)
        {
            ZoomableFindingPhoto {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            .accessibilityLabel(photoAccessibilityLabel(index: index))
        } else if let remoteURL = photo.remoteURL {
            AsyncImage(url: remoteURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .controlSize(.large)
                        .tint(.white)
                case .success(let image):
                    ZoomableFindingPhoto {
                        image
                            .resizable()
                            .scaledToFit()
                    }
                    .accessibilityLabel(photoAccessibilityLabel(index: index))
                case .failure:
                    unavailablePhoto
                @unknown default:
                    unavailablePhoto
                }
            }
        } else {
            unavailablePhoto
        }
    }

    private var unavailablePhoto: some View {
        VStack(spacing: BiologerSpacing.small) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.system(size: 48, weight: .semibold))

            Text("FindingPhotoGallery.unavailable".localized)
                .font(.subheadline.weight(.medium))
        }
        .foregroundColor(.white.opacity(0.72))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var pageCounter: String {
        String(
            format: "FindingPhotoGallery.counter".localized,
            selectedIndex + 1,
            photos.count
        )
    }

    private func photoAccessibilityLabel(index: Int) -> String {
        String(
            format: "FindingPhotoGallery.counter".localized,
            index + 1,
            photos.count
        )
    }
}

private struct ZoomableFindingPhoto<Content: View>: View {
    private let minimumScale: CGFloat = 1
    private let maximumScale: CGFloat = 4
    private let content: () -> Content

    @State private var scale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1
    @GestureState private var gestureOffset: CGSize = .zero

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(displayedScale)
                .offset(displayedOffset)
                .contentShape(Rectangle())
                .simultaneousGesture(magnificationGesture(in: proxy.size))
                .gesture(
                    dragGesture(in: proxy.size),
                    including: scale > minimumScale ? .all : .none
                )
                .onTapGesture(count: 2) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        scale = scale > minimumScale ? minimumScale : 2.5
                        offset = .zero
                    }
                }
        }
        .clipped()
    }

    private var displayedScale: CGFloat {
        clampedScale(scale * gestureScale)
    }

    private var displayedOffset: CGSize {
        guard displayedScale > minimumScale else { return .zero }
        return CGSize(
            width: offset.width + gestureOffset.width,
            height: offset.height + gestureOffset.height
        )
    }

    private func magnificationGesture(
        in size: CGSize
    ) -> some Gesture {
        MagnificationGesture()
            .updating($gestureScale) { value, state, _ in
                state = value
            }
            .onEnded { value in
                scale = clampedScale(scale * value)
                offset = clampedOffset(offset, in: size, scale: scale)

                if scale == minimumScale {
                    offset = .zero
                }
            }
    }

    private func dragGesture(in size: CGSize) -> some Gesture {
        DragGesture()
            .updating($gestureOffset) { value, state, _ in
                guard scale > minimumScale else { return }
                state = value.translation
            }
            .onEnded { value in
                guard scale > minimumScale else { return }
                let proposedOffset = CGSize(
                    width: offset.width + value.translation.width,
                    height: offset.height + value.translation.height
                )
                offset = clampedOffset(proposedOffset, in: size, scale: scale)
            }
    }

    private func clampedScale(_ value: CGFloat) -> CGFloat {
        min(max(value, minimumScale), maximumScale)
    }

    private func clampedOffset(
        _ value: CGSize,
        in size: CGSize,
        scale: CGFloat
    ) -> CGSize {
        let maximumX = size.width * (scale - minimumScale) / 2
        let maximumY = size.height * (scale - minimumScale) / 2

        return CGSize(
            width: min(max(value.width, -maximumX), maximumX),
            height: min(max(value.height, -maximumY), maximumY)
        )
    }
}
