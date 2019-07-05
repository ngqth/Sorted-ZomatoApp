//
//  SearchTableViewController.swift
//  Sorted
//
//  Created by NgQuocThang on 1/5/19.
//  Copyright © 2019 NgQuocThang. All rights reserved.
//

import UIKit
import MapKit

class SearchTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var TV: UITableView!
//    var dataArray = NSArray()
    var pin = MKPointAnnotation()
    var newRestaurant = [RestaurantData]()
    var selectRestaurant: RestaurantData?

    override func viewDidLoad() {
        super.viewDidLoad()
        hotelsDataApiHitting()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.newRestaurant.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        cell.selectionStyle = .none
        let result = newRestaurant[indexPath.row]
        cell.nameLabel.text = result.name
        cell.addressLabel.text = result.address
        cell.cuisineLabel.text = result.cuisine
        cell.ratingLabel.text = result.aggregate_rating
        let color = "#" + result.rating_color
        cell.ratingLabel.layer.borderWidth = 2
        cell.ratingLabel.layer.cornerRadius = 15
        cell.ratingLabel.layer.backgroundColor = UIColor(hexString: color).cgColor
        cell.voteLabel.text = String(result.votes) + " votes"
        return cell
    }
    
    // Search restaurant from coordinate, follow Zomato API
    // Code has reference in credit
    func hotelsDataApiHitting() {
        // Number of fetch result, n = 2
        var start = 0
        // Start fetching process
        let zomatoKey = "0a102def7d2b492f4699a4f8dd6a651a"
        let lat = self.pin.coordinate.latitude, long = self.pin.coordinate.longitude
        // Debug
        // print(lat, long)
        // let lat = -37.799641, long = 144.899765
        // urlString = "https://developers.zomato.com/api/v2.1/search?start=10&count=100lat=\(lat)&lon=\(long)";
        // let urlString = "https://developers.zomato.com/api/v2.1/geocode?lat=\(lat)&lon=\(long)"
        
        // Fetch 2 times
        // NOTE: sometimes, 2nd fetch is added before adding 1st fetch, resulting in list isn't in distance ascensding order.
        for _ in 0 ... 1 {
            let urlString = "https://developers.zomato.com/api/v2.1/search?count=100&lat=\(lat)&lon=\(long)&sort=real_distance&start=\(start)"
            
            let url = NSURL(string: urlString)
            if url != nil {
                let request = NSMutableURLRequest(url: url! as URL)
                request.httpMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue(zomatoKey, forHTTPHeaderField: "user_key")
                
                let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) -> Void in
                    if error == nil {
                        let httpResponse = response as! HTTPURLResponse
                        if httpResponse.statusCode == 200 {
                            do {
                                // Follow tutorial
                                let decoder = JSONDecoder()
                                let restData = try decoder.decode(RestaurantListData.self, from: data!)
                                //self.newRestaurant.append(restData.restaurants!)
                                self.newRestaurant = self.newRestaurant + restData.restaurants!
                                // Ensure fetch result to display in correct ascending order
                                DispatchQueue.main.async {
                                    self.TV.reloadData()
                                }
                            } catch {
                                print(error)
                            }
                        }
                    }
                })
                task.resume()
            }
            start += 20
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectRestaurant = self.newRestaurant[indexPath.row]
//        print(self.newRestaurant[indexPath.row])
        self.performSegue(withIdentifier: "showSearchDetail", sender: nil)
//        print(self.selectRestaurant?.longitude as Any)
//        tableView.deselectRow(at: [indexPath.row], animated: true)
//        print("Here")
    }
    
    // Carry restaurant detail to detail view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSearchDetail" {
            let controller = segue.destination as! DetailViewController
            controller.restaurant = self.selectRestaurant
            controller.fromSearch = true
            controller.inFavourite = false
            controller.id = Int(self.selectRestaurant!.id)
        }
    }
}

// Function convert from hex color to UIColor
// Code is reference in credit
extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
