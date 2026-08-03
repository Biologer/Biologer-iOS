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
    @Published var showsLocationSelection = false
}

@MainActor
struct FindingEditorFlow: View {
    @StateObject private var navigation: FindingEditorFlowNavigation
    @StateObject private var viewModel: FindingEditorV2ViewModel
    private let searchTaxa: SearchFindingTaxaUseCase
    private let locationUseCases: FindingLocationUseCases

    init(
        mode: FindingEditorMode,
        loadFinding: LoadFindingEditorUseCase,
        saveFinding: SaveFindingEditorUseCase,
        searchTaxa: SearchFindingTaxaUseCase,
        locationUseCases: FindingLocationUseCases,
        onSaved: @escaping (UUID) -> Void,
        onAddPhoto: @escaping (FindingEditorPhotoSource) -> Void
    ) {
        let navigation = FindingEditorFlowNavigation()
        self.searchTaxa = searchTaxa
        self.locationUseCases = locationUseCases
        _navigation = StateObject(wrappedValue: navigation)
        _viewModel = StateObject(
            wrappedValue: FindingEditorV2ViewModel(
                mode: mode,
                loadFinding: loadFinding,
                saveFinding: saveFinding,
                onSaved: onSaved,
                onSelectLocation: { _ in
                    navigation.showsLocationSelection = true
                },
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
            .navigationDestination(isPresented: $navigation.showsLocationSelection) {
                FindingLocationFlow(
                    initialLocation: viewModel.draft.location,
                    useCases: locationUseCases,
                    onSelect: { location in
                        viewModel.updateLocation(location)
                        navigation.showsLocationSelection = false
                    }
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
