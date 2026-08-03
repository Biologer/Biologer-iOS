import GoogleMaps
import SwiftUI

struct FindingLocationMapView: UIViewRepresentable {
    let selectedLocation: FindingEditorLocation?
    let cameraTarget: FindingLocationCameraTarget
    let mapStyle: FindingLocationMapStyle
    let onCoordinateSelected: (Double, Double) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> GMSMapView {
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(
            withLatitude: cameraTarget.latitude,
            longitude: cameraTarget.longitude,
            zoom: 15
        )
        let mapView = GMSMapView(options: options)
        mapView.delegate = context.coordinator
        mapView.settings.compassButton = true
        mapView.settings.rotateGestures = false
        context.coordinator.lastCameraTargetID = cameraTarget.id
        context.coordinator.updateSelection(selectedLocation, on: mapView)
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        context.coordinator.parent = self
        mapView.mapType = mapStyle.googleMapType
        context.coordinator.updateSelection(selectedLocation, on: mapView)

        guard context.coordinator.lastCameraTargetID != cameraTarget.id else {
            return
        }
        context.coordinator.lastCameraTargetID = cameraTarget.id
        mapView.animate(
            toLocation: CLLocationCoordinate2D(
                latitude: cameraTarget.latitude,
                longitude: cameraTarget.longitude
            )
        )
    }

    final class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: FindingLocationMapView
        var lastCameraTargetID: UUID?
        private let marker = GMSMarker()
        private let accuracyCircle = GMSCircle()

        init(parent: FindingLocationMapView) {
            self.parent = parent
            super.init()
            marker.isDraggable = true
            marker.icon = GMSMarker.markerImage(with: BiologerUIColor.accent)
            accuracyCircle.strokeColor = BiologerUIColor.accent.withAlphaComponent(0.75)
            accuracyCircle.fillColor = BiologerUIColor.accent.withAlphaComponent(0.14)
            accuracyCircle.strokeWidth = 1.5
        }

        func updateSelection(
            _ location: FindingEditorLocation?,
            on mapView: GMSMapView
        ) {
            guard let location else {
                marker.map = nil
                accuracyCircle.map = nil
                return
            }

            let coordinate = CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )
            marker.position = coordinate
            marker.map = mapView
            accuracyCircle.position = coordinate
            accuracyCircle.radius = max(location.accuracy, 1)
            accuracyCircle.map = mapView
        }

        func mapView(
            _ mapView: GMSMapView,
            didTapAt coordinate: CLLocationCoordinate2D
        ) {
            parent.onCoordinateSelected(coordinate.latitude, coordinate.longitude)
        }

        func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
            parent.onCoordinateSelected(
                marker.position.latitude,
                marker.position.longitude
            )
        }
    }
}

private extension FindingLocationMapStyle {
    var googleMapType: GMSMapViewType {
        switch self {
        case .standard:
            .normal
        case .hybrid:
            .hybrid
        case .terrain:
            .terrain
        case .satellite:
            .satellite
        }
    }
}
