import Combine
import Foundation
import SwiftUI

private enum FindingsDestination: Hashable {
    case details(UUID)
}

private struct FindingPhotoGalleryPresentation: Identifiable {
    let id = UUID()
    let photos: [FindingPhoto]
    let initialIndex: Int
}

@MainActor
private final class FindingsFlowNavigation: ObservableObject {
    @Published var path: [FindingsDestination] = []
    @Published var photoGallery: FindingPhotoGalleryPresentation?
}

@MainActor
struct FindingsFlow: View {
    private let getFindingDetails: GetFindingDetailsUseCase
    private let uploadFindings: UploadFindingsUseCase
    private let onEditFinding: Observer<UUID>
    private let onShowLocation: Observer<FindingDetailsLocation>

    @StateObject private var navigation: FindingsFlowNavigation
    @StateObject private var listViewModel: ListOfFindingsV2ViewModel

    init(
        listUseCases: FindingsUseCases,
        getFindingDetails: GetFindingDetailsUseCase,
        uploadFindings: UploadFindingsUseCase,
        onAddFinding: @escaping Observer<Void>,
        onEditFinding: @escaping Observer<UUID>,
        onShowLocation: @escaping Observer<FindingDetailsLocation>
    ) {
        let navigation = FindingsFlowNavigation()

        self.getFindingDetails = getFindingDetails
        self.uploadFindings = uploadFindings
        self.onEditFinding = onEditFinding
        self.onShowLocation = onShowLocation
        _navigation = StateObject(wrappedValue: navigation)
        _listViewModel = StateObject(
            wrappedValue: ListOfFindingsV2ViewModel(
                useCases: listUseCases,
                onAddFinding: { onAddFinding(()) },
                uploadFindings: uploadFindings
            )
        )
    }

    var body: some View {
        NavigationStack(path: $navigation.path) {
            ListOfFindingsScreenV2(viewModel: listViewModel)
            .navigationDestination(for: FindingsDestination.self) { destination in
                destinationView(destination)
            }
        }
        .onChange(of: listViewModel.navigationFindingID) { id in
            guard let id else { return }
            navigation.path.append(FindingsDestination.details(id))
            listViewModel.didHandleFindingNavigation()
        }
        .fullScreenCover(item: $navigation.photoGallery) { presentation in
            FindingPhotoGalleryScreen(
                photos: presentation.photos,
                initialIndex: presentation.initialIndex,
                onClose: { navigation.photoGallery = nil }
            )
        }
    }

    private func destinationView(_ destination: FindingsDestination) -> some View {
        switch destination {
        case .details(let id):
            FindingDetailsScreenV2(
                viewModel: FindingDetailsV2ViewModel(
                    findingID: id,
                    getFindingDetails: getFindingDetails,
                    uploadFindings: uploadFindings,
                    onEditFinding: onEditFinding,
                    onShowLocation: onShowLocation,
                    onShowPhotos: { photos, initialIndex in
                        navigation.photoGallery = FindingPhotoGalleryPresentation(
                            photos: photos,
                            initialIndex: initialIndex
                        )
                    }
                )
            )
        }
    }
}
