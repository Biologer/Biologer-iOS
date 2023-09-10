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
    @IBOutlet weak var accuracyLabel: UILabel!
    
    public let viewModel: TaxonMapScreenViewModel
    public let getAltitudeService: GetAltitudeService
    private let zoom: Float = 15.0
    private let defaultAccuracy: Double = 25.00
    
    private var desiredAccuracy: Double?
    private var mapView = GMSMapView()
    private var myMarker = GMSMarker()
    private var circle = GMSCircle()
    private var temporaryMarker = GMSMarker()
    
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
    
    init(viewModel: TaxonMapScreenViewModel,
         getAltitudeService: GetAltitudeService) {
        self.viewModel = viewModel
        self.getAltitudeService = getAltitudeService
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
        circle = GMSCircle(position: viewModel.location, radius: defaultAccuracy)
        circle.map = mapView
        circle.fillColor = .biologerGreenColor
        
        viewModel.onMapTypeUpdate = { [weak self] _ in
            guard let self = self else { return }
            self.mapView.mapType = self.getMapType
            self.setAaccuracyLabeColor()
        }
        setAccuracyLabel(accuracy: defaultAccuracy)
        
        self.mapViewContent.addSubview(mapView)
        self.mapViewContent.bringSubviewToFront(currentLocationButton)
        self.mapViewContent.bringSubviewToFront(mapTypeButton)
        self.mapViewContent.bringSubviewToFront(accuracyLabel)
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
        myMarker.iconView = getImageForPicker
        myMarker.map = mapView
        myMarker.isDraggable = true
        myMarker.position = viewModel.location
    }
    
    private var getImageForPicker: UIImageView {
        let imagePicker = UIImageView(image: UIImage(named: "about_icon"))
        imagePicker.frame = CGRect(x: 0, y: 0, width: 35, height: 45)
        return imagePicker
    }
    
    private func updateCameraPosition(newLocation: CLLocationCoordinate2D? = nil) {
        let location = newLocation ?? viewModel.location
        myMarker.position = location
        temporaryMarker.position = location
        myMarker.isDraggable = true
        circle.position = location
        mapView.animate(toLocation: location)
        setAccuracyLabel(accuracy: defaultAccuracy)
        getAltitude(latitude: location.latitude, longitude: location.longitude)
    }
    
    private func setAccuracyLabel(accuracy: Double) {
        accuracyLabel.text = "NewTaxon.map.accuracy.text".localized + " " + String(accuracy) + "m" + "\n" + "NewTaxon.map.accuracy.description".localized
        accuracyLabel.font = UIFont.systemFont(ofSize: titleFontSize)
        accuracyLabel.textColor = .darkText
    }
    
    private func setAaccuracyLabeColor() {
        if getMapType == .hybrid || getMapType == .satellite {
            accuracyLabel.textColor = .white
        } else {
            accuracyLabel.textColor = .black
        }
    }
    
    private func getAltitude(latitude: Double, longitude: Double) {
        getAltitudeService.getAltitude(latitude: latitude,
                                       longitude: longitude) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                let newTaxonLocation = TaxonLocation(latitude: latitude,
                                                     longitute: longitude)
                self.viewModel.doneTapped(taxonLocation: newTaxonLocation)
                print("Get Altitude error: \(error.description)")
            case .success(let response):
                let newTaxonLocation = TaxonLocation(latitude: latitude,
                                                     longitute: longitude,
                                                     accuracy: self.desiredAccuracy ?? self.defaultAccuracy,
                                                     altitude: Double(response.elevation))
                self.viewModel.doneTapped(taxonLocation: newTaxonLocation)
            }
        }
    }
}

extension TaxonMapScreenViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        updateCameraPosition(newLocation: coordinate)
    }
    
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        print("Start location lat: \(viewModel.location.latitude) long: \(viewModel.location.longitude)")
        
        if temporaryMarker.map == nil {
            marker.iconView = UIImageView(image: UIImage(named: "ic_radius"))
            temporaryMarker.iconView = getImageForPicker
            temporaryMarker.map = mapView
            temporaryMarker.position = viewModel.location
        }
    }
    
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        let oldLocation = CLLocation(latitude: viewModel.location.latitude,
                                     longitude: viewModel.location.longitude)
        let newLocation = CLLocation(latitude: marker.position.latitude,
                                     longitude: marker.position.longitude)
        let distance = newLocation.distance(from: oldLocation)
        let accuracy = distance.rounded(toPlaces: 2)
        circle.radius = CLLocationDistance(accuracy)
        desiredAccuracy = distance
        setAccuracyLabel(accuracy: accuracy)
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        marker.iconView = getImageForPicker
        marker.position = viewModel.location
        temporaryMarker.map = nil
        getAltitude(latitude: viewModel.location.latitude, longitude: viewModel.location.longitude)
    }
}
