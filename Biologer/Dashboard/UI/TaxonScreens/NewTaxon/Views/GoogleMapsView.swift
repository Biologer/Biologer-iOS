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
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude,
                                              longitude: location.longitude, zoom: zoom)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = context.coordinator
        
//        let button = UIButton()
//        button.addTarget(self, action: #selector("currentLocation"), for: .touchUpInside)
//        mapView.addSubview(button)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(contentsOfFile: "current_location_icon"), for: .normal)
//        let height = button.heightAnchor.constraint(equalToConstant: 50)
//        let width = button.widthAnchor.constraint(equalToConstant: 50)
//        let bottom = button.bottomAnchor.constraint(equalTo: mapView.bottomAnchor)
//        let tralling = button.trailingAnchor.constraint(equalTo: mapView.trailingAnchor)
//        button.addConstraints([height, width, bottom, tralling])
        
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        updateCameraPosition(mapView)
        onTapAtCoordinate((TaxonLocation(latitude: location.latitude, longitute: location.longitude)))
    }
    
    public func updateCameraPosition(_ mapView: GMSMapView, newLocation: CLLocationCoordinate2D? = nil) {
        mapView.clear()
        let imagePicker = UIImageView(image: UIImage(named: "about_icon"))
        let marker = GMSMarker()
        imagePicker.frame = CGRect(x: 0, y: 0, width: 35, height: 45)
        marker.iconView = imagePicker
        marker.map = mapView
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
