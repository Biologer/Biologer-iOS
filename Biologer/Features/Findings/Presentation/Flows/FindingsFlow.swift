import Combine
import Foundation
import SwiftUI

private enum FindingsDestination: Hashable {
    case details(UUID)
    case location(FindingDetailsLocation)
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
protocol FindingsFlowControlling: AnyObject {
    func showListAndReload()
}

@MainActor
final class FindingsFlowController: ObservableObject, FindingsFlowControlling {
    @Published private(set) var reloadRequestID = UUID()

    func showListAndReload() {
        reloadRequestID = UUID()
    }
}

@MainActor
struct FindingsFlow: View {
    private let getFindingDetails: GetFindingDetailsUseCase
    private let uploadFindings: UploadFindingsUseCase
    private let checkSubmissionAccess: CheckFindingSubmissionAccessUseCase
    private let onEditFinding: Observer<UUID>

    @StateObject private var navigation: FindingsFlowNavigation
    @StateObject private var listViewModel: ListOfFindingsViewModel
    @ObservedObject private var controller: FindingsFlowController

    init(
        controller: FindingsFlowController,
        listUseCases: FindingsUseCases,
        getFindingDetails: GetFindingDetailsUseCase,
        uploadFindings: UploadFindingsUseCase,
        checkSubmissionAccess: CheckFindingSubmissionAccessUseCase,
        onAddFinding: @escaping Observer<Void>,
        onEditFinding: @escaping Observer<UUID>
    ) {
        let navigation = FindingsFlowNavigation()

        self.getFindingDetails = getFindingDetails
        self.uploadFindings = uploadFindings
        self.checkSubmissionAccess = checkSubmissionAccess
        self.onEditFinding = onEditFinding
        self.controller = controller
        _navigation = StateObject(wrappedValue: navigation)
        _listViewModel = StateObject(
            wrappedValue: ListOfFindingsViewModel(
                useCases: listUseCases,
                onAddFinding: { onAddFinding(()) },
                uploadFindings: uploadFindings,
                checkSubmissionAccess: checkSubmissionAccess
            )
        )
    }

    var body: some View {
        NavigationStack(path: $navigation.path) {
            ListOfFindingsScreen(viewModel: listViewModel)
            .navigationDestination(for: FindingsDestination.self) { destination in
                destinationView(destination)
            }
        }
        .onChange(of: listViewModel.navigationFindingID) { id in
            guard let id else { return }
            navigation.path.append(FindingsDestination.details(id))
            listViewModel.didHandleFindingNavigation()
        }
        .onChange(of: controller.reloadRequestID) { _ in
            navigation.photoGallery = nil
            navigation.path.removeAll()
            listViewModel.loadFindings()
        }
        .fullScreenCover(item: $navigation.photoGallery) { presentation in
            FindingPhotoGalleryScreen(
                photos: presentation.photos,
                initialIndex: presentation.initialIndex,
                onClose: { navigation.photoGallery = nil }
            )
        }
    }

    @ViewBuilder
    private func destinationView(_ destination: FindingsDestination) -> some View {
        switch destination {
        case .details(let id):
            FindingDetailsScreen(
                viewModel: FindingDetailsViewModel(
                    findingID: id,
                    getFindingDetails: getFindingDetails,
                    uploadFindings: uploadFindings,
                    checkSubmissionAccess: checkSubmissionAccess,
                    onEditFinding: onEditFinding,
                    onShowLocation: { location in
                        navigation.path.append(.location(location))
                    },
                    onShowPhotos: { photos, initialIndex in
                        navigation.photoGallery = FindingPhotoGalleryPresentation(
                            photos: photos,
                            initialIndex: initialIndex
                        )
                    }
                )
            )
        case .location(let location):
            FindingLocationDetailsFlow(location: location)
        }
    }
}
