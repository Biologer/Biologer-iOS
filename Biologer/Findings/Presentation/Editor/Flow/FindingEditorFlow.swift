import SwiftUI

private struct FindingEditorGalleryPresentation: Identifiable {
    let id = UUID()
    let photos: [FindingPhoto]
    let initialIndex: Int
}

@MainActor
private final class FindingEditorFlowNavigation: ObservableObject {
    @Published var photoGallery: FindingEditorGalleryPresentation?
    @Published var showsTaxonSearch = false
}

@MainActor
struct FindingEditorFlow: View {
    @StateObject private var navigation: FindingEditorFlowNavigation
    @StateObject private var viewModel: FindingEditorV2ViewModel
    private let searchTaxa: SearchFindingTaxaUseCase

    init(
        mode: FindingEditorMode,
        loadFinding: LoadFindingEditorUseCase,
        saveFinding: SaveFindingEditorUseCase,
        searchTaxa: SearchFindingTaxaUseCase,
        onSaved: @escaping (UUID) -> Void,
        onSelectLocation: @escaping (FindingEditorLocation?) -> Void,
        onAddPhoto: @escaping (FindingEditorPhotoSource) -> Void
    ) {
        let navigation = FindingEditorFlowNavigation()
        self.searchTaxa = searchTaxa
        _navigation = StateObject(wrappedValue: navigation)
        _viewModel = StateObject(
            wrappedValue: FindingEditorV2ViewModel(
                mode: mode,
                loadFinding: loadFinding,
                saveFinding: saveFinding,
                onSaved: onSaved,
                onSelectLocation: onSelectLocation,
                onSelectTaxon: { navigation.showsTaxonSearch = true },
                onAddPhoto: onAddPhoto,
                onShowPhotos: { photos, initialIndex in
                    navigation.photoGallery = FindingEditorGalleryPresentation(
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
            )
        )
    }

    var body: some View {
        FindingEditorScreenV2(viewModel: viewModel)
            .navigationDestination(isPresented: $navigation.showsTaxonSearch) {
                FindingTaxonSearchScreenV2(
                    viewModel: FindingTaxonSearchV2ViewModel(
                        searchTaxa: searchTaxa,
                        onSelect: { taxon in
                            viewModel.selectTaxon(taxon)
                            navigation.showsTaxonSearch = false
                        }
                    )
                )
            }
            .fullScreenCover(item: $navigation.photoGallery) { presentation in
                FindingPhotoGalleryScreen(
                    photos: presentation.photos,
                    initialIndex: presentation.initialIndex,
                    onClose: { navigation.photoGallery = nil }
                )
            }
    }
}
