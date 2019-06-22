//
//  FavouriteTableViewController.swift
//  Sorted
//
//  Created by NgQuocThang on 28/4/19.
//  Copyright © 2019 NgQuocThang. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FavouriteTableViewController: UITableViewController, DetailViewDelegate {
    
//    var restaurant: Restaurant?
    var favSnapList : [DataSnapshot] = []
    var selectRestaurant: RestaurantFav?
    var newRestaurant = [RestaurantFav]()
//    var newRestaurant = [NSDictionary]()
    var id : Int = 0
    var restId : [Int] = []
    var row : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveSnapshot()
        
        // ATTENTION: require this to make sure tableview will load with data, otherwise will have error.
        // Tableview will laod along with fetching task from data, regardless finish or not
        // 1-second wait is sufficent for user has less than 100 records, on a 4G connection
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Finish loading")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.favSnapList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favouriteCell", for: indexPath) as! FavouriteTableViewCell
        //cell.selectionStyle = .none
        
        let snapshot = favSnapList[indexPath.row]
        //print(snapshot)
        if let restDict = snapshot.value as? [String:AnyObject] {
            if let name = restDict["name"] as? String {
                cell.nameLableFavourite.text = name
            }
            if let add = restDict["add"] as? String {
                cell.addLabelFavourite.text = add
            }
            if let rating = restDict["aggregate_rating"] as? String {
                cell.ratingLabelFavourite.text = rating
            }
            if let cuisine = restDict["cuisine"] as? String {
                cell.cuisineLableFavourite.text = cuisine
            }
            if let color = restDict["rating_color"] as? String {
                cell.ratingLabelFavourite.layer.borderWidth = 2
                cell.ratingLabelFavourite.layer.cornerRadius = 15
                cell.ratingLabelFavourite.layer.backgroundColor = UIColor(hexString: color).cgColor
            }
        }
        return cell
    }
    
    // Selected row will carry restaurant detail to detailview
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.row = indexPath.row
        let snapshot = favSnapList[indexPath.row]
        if let restDict = snapshot.value as? [String:AnyObject] {
            if let id = restDict["id"] as? Int {
                self.id = id
            }
        }
        // Fetch restaurant detail from ID from database
        restDataApiHitting(id) { (result) in
            self.selectRestaurant = result
        }
        // Wait to fetch detail, spinner will start to show.
        // https://stackoverflow.com/questions/29494655/uiactivityindicatorview-spinner-in-uitableviewcell-cannot-start-animating-by-u
        let cell = tableView.cellForRow(at: indexPath) as! FavouriteTableViewCell
        cell.spinner.isHidden = false
        cell.spinner.startAnimating()
        
        // Will fetch 2 times with 1 second time frame
        // Will display error if fail second time
        // Need this fuction as Api has limited the amount of api calls per user_ID.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.selectRestaurant != nil {
                cell.spinner.isHidden = true
                self.performSegue(withIdentifier: "showFavouriteDetail", sender: nil)
            } else {
                self.restDataApiHitting(self.id) { (result) in
                    self.selectRestaurant = result
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if self.selectRestaurant != nil {
                        cell.spinner.isHidden = true
                        self.performSegue(withIdentifier: "showFavouriteDetail", sender: nil)
                    } else {
                        cell.spinner.isHidden = true
                        self.displayMessage(title: "Error", message: "Request Timeout")
                        print("Request Timeout")
                    }
                }
            }
        }
    }
    
    // Go to detailview
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFavouriteDetail" {
            let controller = segue.destination as! DetailViewController
            controller.delegate = self
            controller.favRestaurant = self.selectRestaurant
            controller.id = self.id
            controller.fromSearch = false
            controller.inFavourite = true
        }
    }
    
    // Retrieve snapshot from database, with pre-added detail to display in tableview
    // Tableview will not retrieve detail of all restaurant in fav list as limited api calls
    // Only retrieve selected restaurant
    func retrieveSnapshot() {
        let email = Auth.auth().currentUser?.email
        Database.database().reference().child("addFav").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
            //print(snapshot)
            self.favSnapList.append(snapshot)
            if let restDict = snapshot.value as? [String:AnyObject] {
                if let id = restDict["id"] as? Int {
                    self.restId.append(id)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    // Function to get restaurant data from Api
    // Changes JSON structure to use RestaurantFav
    func restDataApiHitting(_ id: Int, _ completion: @escaping (RestaurantFav) -> ()) {
        let zomatoKey = ""
        //let lat = -37.799641, long = 144.899765
        let urlString = "https://developers.zomato.com/api/v2.1/restaurant?res_id=\(id)"
        //let urlString = "https://developers.zomato.com/api/v2.1/search?count=100&lat=\(lat)&lon=\(long)&sort=real_distance"
        
        let url = NSURL(string: urlString)
        if url != nil {
            let request = NSMutableURLRequest(url: url! as URL)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(zomatoKey, forHTTPHeaderField: "user_key")
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) -> Void in
                if error == nil {
                    let httpResponse = response as! HTTPURLResponse!
                    if httpResponse?.statusCode == 200 {
                        do {
                            let decoder = JSONDecoder()
                            let restData = try decoder.decode(RestaurantFav.self, from: data!)
                            let restaurant = restData
                            completion(restaurant)
                        } catch {
                            print(error)
                        }
                    }
                }
            })
            task.resume()
        }
    }
    
    // Func to display error message
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the error
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Delete delegate, unfavourite from detail will delete from fav list
    func deleteFavourite() {
        self.favSnapList.remove(at: self.row)
        self.tableView.reloadData()
    }
}
