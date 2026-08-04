import SwiftUI

private struct FindingEditorGalleryPresentation: Identifiable {
    let id = UUID()
    let photos: [FindingPhoto]
    let initialIndex: Int
}

private struct FindingEditorPhotoPickerPresentation: Identifiable {
    let id = UUID()
    let source: FindingEditorPhotoSource
}

@MainActor
private final class FindingEditorFlowNavigation: ObservableObject {
    @Published var photoGallery: FindingEditorGalleryPresentation?
    @Published var photoPicker: FindingEditorPhotoPickerPresentation?
    @Published var showsTaxonSearch = false
    @Published var showsTaxonSync = false
    @Published var showsLocationSelection = false
}

@MainActor
struct FindingEditorFlow: View {
    @StateObject private var navigation: FindingEditorFlowNavigation
    @StateObject private var viewModel: FindingEditorV2ViewModel
    private let searchTaxa: SearchFindingTaxaUseCase
    private let locationUseCases: FindingLocationUseCases
    private let taxonSyncComposition: TaxonSyncComposition

    init(
        mode: FindingEditorMode,
        loadFinding: LoadFindingEditorUseCase,
        saveFinding: SaveFindingEditorUseCase,
        searchTaxa: SearchFindingTaxaUseCase,
        locationUseCases: FindingLocationUseCases,
        taxonSyncComposition: TaxonSyncComposition,
        onSaved: @escaping (UUID) -> Void,
        onUnsavedChangesChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        let navigation = FindingEditorFlowNavigation()
        self.searchTaxa = searchTaxa
        self.locationUseCases = locationUseCases
        self.taxonSyncComposition = taxonSyncComposition
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
                onAddPhoto: { source in
                    navigation.photoPicker = FindingEditorPhotoPickerPresentation(
                        source: source
                    )
                },
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
                },
                onUnsavedChangesChanged: onUnsavedChangesChanged
            )
        )
    }

    var body: some View {
        NavigationStack {
            FindingEditorScreenV2(viewModel: viewModel)
                .navigationDestination(isPresented: $navigation.showsTaxonSearch) {
                    FindingTaxonSearchScreenV2(
                        viewModel: FindingTaxonSearchV2ViewModel(
                            searchTaxa: searchTaxa,
                            onSelect: { taxon in
                                viewModel.selectTaxon(taxon)
                                navigation.showsTaxonSearch = false
                            }
                        ),
                        onTaxonSync: {
                            navigation.showsTaxonSync = true
                        }
                    )
                }
                .navigationDestination(isPresented: $navigation.showsTaxonSync) {
                    TaxonSyncFlow(
                        useCases: taxonSyncComposition.useCases,
                        scopeProvider: taxonSyncComposition.scopeProvider
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
        }
        .sheet(item: $navigation.photoPicker) { presentation in
            FindingEditorImagePicker(
                source: presentation.source,
                onSelect: { photo in
                    viewModel.addPhoto(photo)
                    navigation.photoPicker = nil
                },
                onCancel: { navigation.photoPicker = nil }
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
