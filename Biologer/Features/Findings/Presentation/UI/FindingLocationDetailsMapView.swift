import GoogleMaps
import SwiftUI

struct FindingLocationDetailsMapView: UIViewRepresentable {
    let location: FindingDetailsLocation
    let mapStyle: FindingLocationDetailsMapStyle

    func makeUIView(context: Context) -> UIView {
        guard !isRunningInCanvas else {
            return makeCanvasPlaceholder()
        }

        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(
            withLatitude: location.latitude,
            longitude: location.longitude,
            zoom: 17
        )
        let mapView = GMSMapView(options: options)
        mapView.settings.compassButton = true
        mapView.settings.rotateGestures = false
        configureAnnotations(on: mapView)
        return mapView
    }

    func updateUIView(_ view: UIView, context: Context) {
        guard let mapView = view as? GMSMapView else { return }
        mapView.mapType = mapStyle.googleMapType
    }

    private var isRunningInCanvas: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    private func makeCanvasPlaceholder() -> UIView {
        let view = UIView()
        view.backgroundColor = BiologerUIColor.iconBackground

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "FindingLocationDetails.canvas.placeholder".localized
        label.textColor = BiologerUIColor.textPrimary
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .center
        label.numberOfLines = 0
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: 24
            ),
            label.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -24
            )
        ])
        return view
    }

    private func configureAnnotations(on mapView: GMSMapView) {
        let coordinate = CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )

        let marker = GMSMarker(position: coordinate)
        marker.icon = GMSMarker.markerImage(with: BiologerUIColor.accent)
        marker.map = mapView

        let accuracyCircle = GMSCircle(position: coordinate, radius: max(location.accuracy, 1))
        accuracyCircle.strokeColor = BiologerUIColor.accent.withAlphaComponent(0.75)
        accuracyCircle.fillColor = BiologerUIColor.accent.withAlphaComponent(0.14)
        accuracyCircle.strokeWidth = 1.5
        accuracyCircle.map = mapView
    }
}

private extension FindingLocationDetailsMapStyle {
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
