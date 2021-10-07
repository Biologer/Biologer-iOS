//
//  TaxonMapScreenViewController.swift
//  Biologer
//
//  Created by Nikola Popovic on 7.10.21..
//

import UIKit
import GoogleMaps

class TaxonMapScreenViewController: UIViewController {
    
    @IBOutlet weak var mapViewContent: UIView!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var mapTypeButton: UIButton!
    
    public let viewModel: TaxonMapScreenViewModel
    private let zoom: Float = 15.0
    
    private var mapView = GMSMapView()
    private var marker = GMSMarker()
    
    private var getMapType: GMSMapViewType {
        switch viewModel.mapType {
        case .normal:
            return .normal
        case .hybrid:
            return .hybrid
        case .terrain:
            return .terrain
        case .satellite:
            return .satellite
        }
    }
    
    init(viewModel: TaxonMapScreenViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: viewModel.location.latitude,
                                              longitude: viewModel.location.longitude, zoom: zoom)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        mapView.mapType = getMapType
        createMarker()
        mapView.delegate = self
        
        viewModel.onMapTypeUpdate = { _ in
            self.mapView.mapType = self.getMapType
        }
        
        self.mapViewContent.addSubview(mapView)
        self.mapViewContent.bringSubviewToFront(currentLocationButton)
        self.mapViewContent.bringSubviewToFront(mapTypeButton)
    }
    
    // MARK: - Actions
    @IBAction func currentLocationTapped(_ button: UIButton) {
        viewModel.setMarkerToCurrentLocation()
        updateCameraPosition()
    }
    
    @IBAction func mapTypeTapped(_ button: UIButton) {
        viewModel.mapTypeTapped()
    }
    
    // MARK: - Private Functions
    private func createMarker() {
        marker.iconView = getImageForPicker
        marker.map = mapView
        marker.position = viewModel.location
    }
    
    private var getImageForPicker: UIImageView {
        let imagePicker = UIImageView(image: UIImage(named: "about_icon"))
        imagePicker.frame = CGRect(x: 0, y: 0, width: 35, height: 45)
        return imagePicker
    }
    
    private func updateCameraPosition(newLocation: CLLocationCoordinate2D? = nil) {
        let location = newLocation ?? viewModel.location
        marker.position = location
        mapView.animate(toLocation: location)
        let newTaxonLocation = TaxonLocation(latitude: location.latitude,
                                                longitute: location.longitude)
        viewModel.doneTapped(taxonLocation: newTaxonLocation)
    }
}

extension TaxonMapScreenViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        updateCameraPosition(newLocation: coordinate)
    }
}
