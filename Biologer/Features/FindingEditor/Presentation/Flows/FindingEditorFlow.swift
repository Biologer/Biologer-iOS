import SwiftUI

@MainActor
struct FindingEditorFlow: View {
    private enum Destination: Hashable {
        case taxonSearch
        case taxonSync
        case location(FindingEditorLocation?)
    }

    private struct GalleryPresentation: Identifiable {
        let id = UUID()
        let photos: [FindingPhoto]
        let initialIndex: Int
    }

    private struct PhotoPickerPresentation: Identifiable {
        let id = UUID()
        let source: FindingEditorPhotoSource
    }

    @State private var path: [Destination] = []
    @State private var photoGallery: GalleryPresentation?
    @State private var photoPicker: PhotoPickerPresentation?
    @StateObject private var viewModel: FindingEditorFlowViewModel

    private let locationUseCases: FindingLocationUseCases
    private let onSaved: Observer<UUID>

    init(
        viewModel: FindingEditorFlowViewModel,
        locationUseCases: FindingLocationUseCases,
        onSaved: @escaping Observer<UUID>
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.locationUseCases = locationUseCases
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack(path: $path) {
            FindingEditorScreen(
                viewModel: viewModel.editorViewModel,
                onSaved: onSaved,
                onSelectLocation: { location in
                    path.append(.location(location))
                },
                onSelectTaxon: {
                    path.append(.taxonSearch)
                },
                onAddPhoto: { source in
                    photoPicker = PhotoPickerPresentation(source: source)
                },
                onShowPhotos: showPhotos
            )
            .navigationDestination(for: Destination.self) { destination in
                destinationView(destination)
            }
        }
        .sheet(item: $photoPicker) { presentation in
            FindingEditorImagePicker(
                source: presentation.source,
                onSelect: { photo in
                    viewModel.editorViewModel.addPhoto(photo)
                    photoPicker = nil
                },
                onCancel: { photoPicker = nil }
            )
        }
        .fullScreenCover(item: $photoGallery) { presentation in
            FindingPhotoGalleryScreen(
                photos: presentation.photos,
                initialIndex: presentation.initialIndex,
                onClose: { photoGallery = nil }
            )
        }
    }

    @ViewBuilder
    private func destinationView(_ destination: Destination) -> some View {
        switch destination {
        case .taxonSearch:
            FindingTaxonSearchScreen(
                viewModel: viewModel.taxonSearchViewModel,
                onSelectTaxon: { taxon in
                    viewModel.editorViewModel.selectTaxon(taxon)
                    goBack()
                },
                onTaxonSync: {
                    path.append(.taxonSync)
                }
            )
        case .taxonSync:
            TaxonSyncFlow(viewModel: viewModel.taxonSyncViewModel)
        case .location(let initialLocation):
            FindingLocationScreen(
                initialLocation: initialLocation,
                useCases: locationUseCases,
                onSelect: { location in
                    viewModel.editorViewModel.updateLocation(location)
                    goBack()
                }
            )
        }
    }

    private func showPhotos(
        _ photos: [FindingEditorPhoto],
        initialIndex: Int
    ) {
        photoGallery = GalleryPresentation(
            photos: photos.map {
                FindingPhoto(
                    name: $0.name,
                    imageData: $0.imageData,
                    remoteURL: $0.remoteURL
                )
            },
            initialIndex: initialIndex
        )
    }

    private func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
