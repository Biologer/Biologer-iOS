//
//  GoogleMapsView.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.10.21..
//

import SwiftUI
import GoogleMaps

struct GoogleMapsView: UIViewRepresentable {
    @ObservedObject var locationManager = LocationManager()
    private let zoom: Float = 15.0
    
    func makeUIView(context: Self.Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: locationManager.latitude, longitude: locationManager.longitude, zoom: zoom)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        let location = CLLocationCoordinate2D(latitude: locationManager.latitude, longitude: locationManager.longitude)
        let marker = GMSMarker()
        let imagePicker = UIImageView(image: UIImage(named: "about_icon"))
        imagePicker.frame = CGRect(x: 0, y: 0, width: 35, height: 45)
        marker.iconView = imagePicker
        marker.position = location
        marker.map = mapView
        mapView.animate(toLocation: location)
    }
}
