//
//  GoogleMapsView.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.10.21..
//

import SwiftUI
import GoogleMaps

struct GoogleMapsView: UIViewRepresentable {
    let locationManager: LocationManager
    let taxonLocation: TaxonLocation?
    let onTapAtCoordinate: Observer<TaxonLocation>
    private let zoom: Float = 15.0
    
    var location: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: taxonLocation?.latitude ?? locationManager.latitude,
                                      longitude: taxonLocation?.longitute ?? locationManager.longitude)
    }
    
    private var getImageForPicker: UIImageView {
        let imagePicker = UIImageView(image: UIImage(named: "about_icon"))
        imagePicker.frame = CGRect(x: 0, y: 0, width: 35, height: 45)
        return imagePicker
    }
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude,
                                              longitude: location.longitude, zoom: zoom)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        updateCameraPosition(mapView)
        onTapAtCoordinate((TaxonLocation(latitude: location.latitude, longitute: location.longitude)))
    }
    
    public func updateCameraPosition(_ mapView: GMSMapView, newLocation: CLLocationCoordinate2D? = nil) {
        mapView.clear()
        createMarker(mapView: mapView,
                     location: newLocation ?? location)
        mapView.animate(toLocation: newLocation ?? location)
    }
    
    public func makeCoordinator() -> GoogleMapsViewDelegate {
        GoogleMapsViewDelegate(googleMapsView: self, onTapAtCoordinate: onTapAtCoordinate)
    }
    
    private func createMarker(mapView: GMSMapView,
                              location: CLLocationCoordinate2D) {
        let marker = GMSMarker()
        marker.iconView = getImageForPicker
        marker.map = mapView
        marker.position = location
    }
    
    public class GoogleMapsViewDelegate: NSObject, GMSMapViewDelegate {
        
        private let googleMapsView: GoogleMapsView
        private let onTapAtCoordinate: Observer<TaxonLocation>
        
        init(googleMapsView: GoogleMapsView,
             onTapAtCoordinate: @escaping Observer<TaxonLocation>) {
            self.googleMapsView = googleMapsView
            self.onTapAtCoordinate = onTapAtCoordinate
        }
        
        public func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            googleMapsView.updateCameraPosition(mapView, newLocation: coordinate)
            onTapAtCoordinate((TaxonLocation(latitude: coordinate.latitude, longitute: coordinate.longitude)))
            print("Location tapped: \r\n Lat: \(coordinate.latitude) \r\n Lon: \(coordinate.longitude) \r\n Acc: \("coordinate.accuracy") \r\n Alt: \("coordinate.altitude")")
        }
    }
}
