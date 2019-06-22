//
//  DetailViewController.swift
//  Sorted
//
//  Created by NgQuocThang on 2/5/19.
//  Copyright © 2019 NgQuocThang. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase

protocol DetailViewDelegate: class {
    func deleteFavourite()
}

class DetailViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cuisineLabel: UILabel!
    @IBOutlet weak var priceRangeLabel: UILabel!
    @IBOutlet weak var costFor2Label: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addToFavourite: UIButton!
    @IBOutlet weak var addPhotos: UIButton!
    @IBOutlet weak var gallery: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    
    //@IBOutlet var addToFavourite: RaisedButton!
    //@IBOutlet var addPhotos: RaisedButton!
    //@IBOutlet var gallery: RaisedButton!
    
    var fromSearch = true
    var inFavourite = false
    var restaurant: RestaurantData!
    var favRestaurant: RestaurantFav!
    var long: Double?
    var lat: Double?
    var id : Int?
    var locationManager = CLLocationManager()
    var ref: DataSnapshot!
    var key: String!
    var emailid: String = ""
    weak var delegate: DetailViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Button UI
        addPhotos.layer.cornerRadius = 25
        gallery.layer.cornerRadius = 25
        
        // Get email from Firebase
        let email = Auth.auth().currentUser?.email
        let email_id = email! + "_" + String(self.id!)
        
        // Check if the restaurant already in favourite list or not
        // Call only one
        // https://firebase.google.com/docs/database/ios/read-and-write
        Database.database().reference().child("addFav").queryOrdered(byChild: "email_id").queryEqual(toValue: email_id).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            self.emailid = email_id
            self.key = snapshot.key
            self.inFavourite = true
            self.addToFavourite.setTitle("❤️", for: .normal)
            self.addPhotos.isEnabled = true
            self.gallery.isEnabled = true
            self.addPhotos.isHidden = false
            self.gallery.isHidden = false
        }) { (error) in
            self.inFavourite = false
            self.addToFavourite.setTitle("★", for: .normal)
            self.addPhotos.isHidden = true
            self.gallery.isHidden = true
        }
        //Database.database().reference().child("addFav").queryOrdered(byChild: "email_id").queryEqual(toValue: email_id).observe(.childAdded) { (snapshot) in
            //self.key = snapshot.key
            //self.ref = snapshot
            //print(snapshot)
        //}
        
        // If from search, restaurant might or might not be in Fav list, so hide photo/gallery buttons
        if fromSearch {
            if !inFavourite {
                self.addToFavourite.setTitle("★", for: .normal)
                self.addPhotos.isHidden = true
                self.gallery.isHidden = true
            }
            self.title = self.restaurant?.name
            if let lat = self.restaurant?.latitude, let doubleLat = Double(lat) {
                self.lat = doubleLat
            }
            if let long = self.restaurant?.longitude, let doubleLong = Double(long) {
                self.long = doubleLong
            }
            if let id = self.restaurant?.id, let intId = Int(id) {
                self.id = intId
            }
            
            // Get coor and direction
            mapView.delegate = self
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            // Do any additional setup after loading the view.
            self.cuisineLabel.text = self.restaurant.cuisine
            self.ratingLabel.text = self.restaurant.aggregate_rating
            let color = "#" + self.restaurant.rating_color
            self.ratingLabel.layer.borderWidth = 2
            self.ratingLabel.layer.cornerRadius = 15
            self.ratingLabel.layer.backgroundColor = UIColor(hexString: color).cgColor
            self.addressLabel.text = self.restaurant.address
            self.phoneLabel.text = self.restaurant.phone_numbers
            self.voteLabel.text = String(self.restaurant.votes) + " votes"
            var temp = ""
            for _ in 1 ... self.restaurant!.price_range {
                temp += "$"
            }
            self.priceRangeLabel.text = temp
            self.costFor2Label.text = self.restaurant.currency + String(self.restaurant.average_cost_for_two)
        } else {
            // From Fav list, no need to hide buttons
            self.title = self.favRestaurant?.name
            if let lat = self.favRestaurant?.latitude, let doubleLat = Double(lat) {
                self.lat = doubleLat
            }
            if let long = self.favRestaurant?.longitude, let doubleLong = Double(long) {
                self.long = doubleLong
            }
            if let id = self.favRestaurant?.id, let intId = Int(id) {
                self.id = intId
            }
            mapView.delegate = self
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            // Do any additional setup after loading the view.
            self.cuisineLabel.text = self.favRestaurant.cuisine
            self.ratingLabel.text = self.favRestaurant.aggregate_rating
            let color = "#" + self.favRestaurant.rating_color
            self.ratingLabel.layer.borderWidth = 2
            self.ratingLabel.layer.cornerRadius = 15
            self.ratingLabel.layer.backgroundColor = UIColor(hexString: color).cgColor
            self.addressLabel.text = self.favRestaurant.address
            self.phoneLabel.text = self.favRestaurant.phone_numbers
            self.voteLabel.text = String(self.favRestaurant.votes) + " votes"
            var temp = ""
            for _ in 1 ... self.favRestaurant!.price_range {
                temp += "$"
            }
            self.priceRangeLabel.text = temp
            self.costFor2Label.text = self.favRestaurant.currency + String(self.favRestaurant.average_cost_for_two)
        }
    }
    
    // Add restaurant to fav, or remove it
    @IBAction func addToFavourite(_ sender: Any) {
        if let email = Auth.auth().currentUser?.email {
            
            // If restaurant in fav, remove it from list, as well as hide all button include favourite button
            // If dont hide fav button, re-add restaurant will cause error -> need to investigate
            // Only happen when from favourite -> details
            if inFavourite {
                let email_id = email + "_" + String(self.id!)
                Database.database().reference().child("addFav").queryOrdered(byChild: "email_id").queryEqual(toValue: email_id).observeSingleEvent(of: .childAdded, with: { (snapshot) in
                    snapshot.ref.removeValue()
                }) { (error) in
                    return
                }
                delegate?.deleteFavourite()
                addToFavourite.setTitle("★", for: .normal)
                if !fromSearch {
                    addToFavourite.isHidden = true
                }
                addPhotos.isHidden = true
                gallery.isHidden = true
                addPhotos.isEnabled = false
                gallery.isEnabled = false
                inFavourite = false
            } else {
                // Add to favourite, or remove it
                if fromSearch {
                    let email_id = email + "_" + String(self.id!)
                    let addFavDict: [String:Any] = ["email":email, "id": self.id!, "email_id": email_id, "aggregate_rating": self.restaurant.aggregate_rating, "cuisine": self.restaurant.cuisine, "rating_color": "#"+self.restaurant.rating_color, "name": self.restaurant.name, "add": self.restaurant.address]
                    Database.database().reference().child("addFav").childByAutoId().setValue(addFavDict)
                } else {
                    // Redundance because cant add back to fav if from fav list view. Need to fix in the future.
                    let email_id = email + "_" + String(self.id!)
                    let addFavDict: [String:Any] = ["email":email, "id": self.id!, "email_id": email_id, "aggregate_rating": self.favRestaurant.aggregate_rating, "cuisine": self.favRestaurant.cuisine, "rating_color": "#"+self.favRestaurant.rating_color, "name": self.favRestaurant.name, "add":self.restaurant.address]
                    Database.database().reference().child("addFav").childByAutoId().setValue(addFavDict)
                }
                self.inFavourite = true
                addToFavourite.setTitle("❤️", for: .normal)
                addPhotos.isHidden = false
                gallery.isHidden = false
                addPhotos.isEnabled = true
                gallery.isEnabled = true
            }
        }
    }
    
    @IBAction func goToGallery(_ sender: Any) {
        self.performSegue(withIdentifier: "showGallery", sender: nil)
    }
    
    @IBAction func addPhotos(_ sender: Any) {
        self.performSegue(withIdentifier: "postFromDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postFromDetail" {
            let controller = segue.destination as! ComposeViewController
            controller.key = self.key
        }
        if segue.identifier == "showGallery" {
            let controller = segue.destination as! UINavigationController
            let topController = controller.topViewController as! GalleryTableViewController
            //topController.ref = self.ref
            topController.key = self.key
            topController.emailid = self.emailid
        }
    }
    
    // Location function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = manager.location?.coordinate {
            let pin = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
//            let region = MKCoordinateRegion(center: pin, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//            mapView.setRegion(region, animated: true)
            mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin
            annotation.title = "Your Location"
            let restaurantPin = CLLocationCoordinate2D(latitude: self.lat!, longitude: self.long!)
//            let restaurantRegion = MKCoordinateRegion(center: restaurantPin, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            let restaurantAnnotation = MKPointAnnotation()
            restaurantAnnotation.coordinate = restaurantPin
            restaurantAnnotation.title = self.restaurant?.name
            mapView.addAnnotations([restaurantAnnotation, annotation])
            //https://www.ioscreator.com/tutorials/draw-route-mapkit-tutorial
            let sourcePlacemark = MKPlacemark(coordinate: pin, addressDictionary: nil)
            let destinationPlacemark = MKPlacemark(coordinate: restaurantPin, addressDictionary: nil)
            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            
            // Get direction from current location to restaurant location
            // Code has reference in credit
            let directionRequest = MKDirections.Request()
            directionRequest.source = sourceMapItem
            directionRequest.destination = destinationMapItem
            directionRequest.transportType = MKDirectionsTransportType.automobile
            
            let directions = MKDirections(request: directionRequest)
            directions.calculate {
                (response, error) -> Void in
                
                guard let response = response else {
                    if let error = error {
                        print("Error: \(error)")
                    }
                    return
                }
                
                // Print out distant
                let route = response.routes[0]
                if route.distance < 1000 {
                    //print(String(route.distance) + " m")
                    self.distanceLabel.text = String(format: "%.0f", route.distance) + " m"
                } else {
                    //print(String(route.distance / 1000) + " km")
                    self.distanceLabel.text = String(format: "%.1f", route.distance / 1000) + " km"
                }
                
                // Set blue line as direction
                self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
                var rect = route.polyline.boundingMapRect
                let wPadding = rect.size.width * 0.5
                let hPadding = rect.size.height * 0.5
                //Add padding to the region
                rect.size.width += wPadding
                rect.size.height += hPadding
                //Center the region on the line
                rect.origin.x -= wPadding / 2
                rect.origin.y -= hPadding / 2
                self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }
        }
    }
    
    // Blue line setting for direction
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        return renderer
    }
    
    // Func to check if res in fav
    func checkIfFav(email: String, id: Int) {
        let email_id = email + "_" + String(id)
        Database.database().reference().child("addFav").queryOrdered(byChild: "email_id").queryEqual(toValue: email_id).observe(.childAdded, with: { (snapshot) in
            self.inFavourite = true
            Database.database().reference().child("addFav").removeAllObservers()
        })
    }
}
