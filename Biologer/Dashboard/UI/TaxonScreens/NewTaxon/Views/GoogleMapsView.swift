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
    let marker = GMSMarker()
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: taxonLocation?.latitude ?? locationManager.latitude,
                                              longitude: taxonLocation?.longitute ?? locationManager.longitude, zoom: zoom)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        let imagePicker = UIImageView(image: UIImage(named: "about_icon"))
        imagePicker.frame = CGRect(x: 0, y: 0, width: 35, height: 45)
        marker.iconView = imagePicker
        marker.map = mapView
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        updateCameraPosition(mapView)
    }
    
    public func updateCameraPosition(_ mapView: GMSMapView, newLocation: CLLocationCoordinate2D? = nil) {
        let location = CLLocationCoordinate2D(latitude: taxonLocation?.latitude ?? locationManager.latitude,
                                              longitude: taxonLocation?.longitute ?? locationManager.longitude)
        marker.position = newLocation ?? location
        mapView.animate(toLocation: newLocation ?? location)
    }
    
    public func makeCoordinator() -> GoogleMapsViewDelegate {
        GoogleMapsViewDelegate(googleMapsView: self, onTapAtCoordinate: onTapAtCoordinate)
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

extension GMSCameraPosition  {
     static var london = GMSCameraPosition.camera(withLatitude: 51.507, longitude: 0, zoom: 10)
 }
