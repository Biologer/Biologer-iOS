import Foundation
import SwiftUI

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
    private enum Destination: Hashable {
        case details(UUID)
        case location(FindingDetailsLocation)
    }

    private struct PhotoGalleryPresentation: Identifiable {
        let id = UUID()
        let photos: [FindingPhoto]
        let initialIndex: Int
    }

    @State private var path: [Destination] = []
    @State private var photoGallery: PhotoGalleryPresentation?
    @StateObject private var viewModel: FindingsFlowViewModel
    @ObservedObject private var controller: FindingsFlowController

    private let detailsUseCases: FindingDetailsUseCases
    private let onAddFinding: Observer<Void>
    private let onEditFinding: Observer<UUID>

    init(
        viewModel: FindingsFlowViewModel,
        controller: FindingsFlowController,
        detailsUseCases: FindingDetailsUseCases,
        onAddFinding: @escaping Observer<Void>,
        onEditFinding: @escaping Observer<UUID>
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.controller = controller
        self.detailsUseCases = detailsUseCases
        self.onAddFinding = onAddFinding
        self.onEditFinding = onEditFinding
    }

    var body: some View {
        NavigationStack(path: $path) {
            ListOfFindingsScreen(
                viewModel: viewModel.listViewModel,
                onAddFinding: { onAddFinding(()) },
                onSelectFinding: { path.append(.details($0)) }
            )
            .navigationDestination(for: Destination.self) { destination in
                destinationView(destination)
            }
        }
        .onChange(of: controller.reloadRequestID) { _ in
            photoGallery = nil
            path.removeAll()
            viewModel.listViewModel.loadFindings()
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
        case .details(let findingID):
            FindingDetailsScreen(
                findingID: findingID,
                useCases: detailsUseCases,
                onEditFinding: onEditFinding,
                onShowLocation: { path.append(.location($0)) },
                onShowPhotos: { photos, initialIndex in
                    photoGallery = PhotoGalleryPresentation(
                        photos: photos,
                        initialIndex: initialIndex
                    )
                }
            )
        case .location(let location):
            FindingLocationDetailsScreen(location: location)
        }
    }
}
