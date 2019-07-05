//
//  SearchViewController.swift
//  Sorted
//
//  Created by NgQuocThang on 28/4/19.
//  Copyright © 2019 NgQuocThang. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import Material

protocol searchCoorDelegate: class {
    func searchCoor(_ coordinate: MKPointAnnotation)
}

class SearchViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {

    @IBOutlet var searchButton: RaisedButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var favouriteBarButton: UIBarButtonItem!
    
    var locationManager = CLLocationManager()
    var newPin = MKPointAnnotation()
    var delegate: searchCoorDelegate?
    var city: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Search button UI
        searchButton.layer.cornerRadius = 25
        
        // Search bar
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find Location"
        //https://stackoverflow.com/questions/35302760/how-to-change-the-colour-of-the-cancel-button-on-the-uisearchbar-in-swift
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white], for: .normal)
        navigationItem.searchController = searchController
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.setTextFieldColor(color: Color.white)
        definesPresentationContext = true
        
        // Get current location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Do any additional setup after loading the view.
        // Add gesture recognizer
        let tapPress = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.mapTap(_:))) // colon needs to pass through info
        mapView.addGestureRecognizer(tapPress)
    }
    
    // Location function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = manager.location?.coordinate {
            let pin = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let region = MKCoordinateRegion(center: pin, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(region, animated: true)
            mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin
            annotation.title = "Your Search Location"
            mapView.addAnnotation(annotation)
            self.newPin = annotation
            print(self.newPin.coordinate)
//            delegate?.searchCoor(self.newPin)
        }
    }
    
    // Search city from input and get coord
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, searchText.count > 0 else {
            return;
        }
        self.city = searchText
        fetchCityCoor()
        print(self.newPin.coordinate)
    }
    
    // Get coor from city name
    func fetchCityCoor() {
        let location = self.city
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { [weak self] placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                let mark = MKPlacemark(placemark: placemark)
                if var region = self?.mapView.region {
                    // Set up region on Map
                    region.center = location.coordinate
                    region.span.longitudeDelta = 0.01
                    region.span.latitudeDelta = 0.01
                    self?.mapView.setRegion(region, animated: true)
                    self?.mapView.addAnnotation(mark)
                    self?.newPin.coordinate.latitude = location.coordinate.latitude
                    self?.newPin.coordinate.longitude = location.coordinate.longitude
                }
            }
        }
    }
    
    // Logout
    @IBAction func logoutTap(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // Search
    @IBAction func searchTap(_ sender: Any) {
        self.performSegue(withIdentifier: "searchSegue", sender: nil)
    }
    
    // Go to Fav
    @IBAction func favouriteTap(_ sender: Any) {
        self.performSegue(withIdentifier: "showFavouriteSegue", sender: nil)
    }
    
    // Gesture controll, tap on map -> get coor
    // https://stackoverflow.com/questions/14580269/get-tapped-coordinates-with-iphone-mapkit
    @objc func mapTap(_ recognizer: UIGestureRecognizer) {
        print("Change location")
        let touchedAt = recognizer.location(in: self.mapView) // adds the location on the view it was pressed
        let touchedAtCoordinate : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView) // will get coordinates
        self.newPin.coordinate = touchedAtCoordinate
        // Debug
        print(self.newPin.coordinate)
        // Add new pin on map
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(self.newPin)
    }
    
    // Go to search api, carry forward pin coordinate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchSegue" {
            let controller = segue.destination as! SearchTableViewController
            controller.pin = self.newPin
        }
    }
    
    // Error display function, will implement later
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

// Change UI for search bar, make text input field white, change cancel button color
// https://stackoverflow.com/questions/13817330/how-to-change-inside-background-color-of-uisearchbar-component-on-ios
extension UISearchBar {
    
    private func getViewElement<T>(type: T.Type) -> T? {
        
        let svs = subviews.flatMap { $0.subviews }
        guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
        return element
    }
    
    func setTextFieldColor(color: UIColor) {
        
        if let textField = getViewElement(type: UITextField.self) {
            switch searchBarStyle {
            case .minimal:
                textField.layer.backgroundColor = color.cgColor
                textField.layer.cornerRadius = 6
                
            case .prominent, .default:
                textField.backgroundColor = color
            @unknown default:
                fatalError()
            }
        }
    }
}
