//
//  GalleryTableViewController.swift
//  Sorted
//
//  Created by NgQuocThang on 17/5/19.
//  Copyright © 2019 NgQuocThang. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SwiftyJSON
import Firebase


class GalleryTableViewController: UITableViewController {

    var ref: DataSnapshot!
    var postcount: Int = 0
    var posts = [Post]()
    var key: String = ""
    var emailid: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observe if new photo is added -> add to tableview
        Database.database().reference().child("addFav").child(self.key).child("photos").observe(.childAdded) { (snapshot) in
            //print(snapshot)
            let json = JSON(snapshot.value!)
            //print(json)
            self.postcount = json.count
            let newPost = Post(ref: (key: snapshot.key, json: json))
            //print(newPost)
            // Add on top of table view
            // Code has reference in credit
            DispatchQueue.main.async {
                self.posts.insert(newPost, at: 0)
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .top)
            }
        }
        
        // Observe if photo is deleted
        Database.database().reference().child("addFav").child(self.key).child("photos").observe(.childRemoved) { (snapshot) in
            //print(snapshot)
            let json = JSON(snapshot.value!)
            self.postcount = self.postcount - json.count
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    @IBAction func doneButton(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "galleryCell", for: indexPath) as! GalleryTableViewCell
        cell.selectionStyle = .none
        let post = self.posts[indexPath.row]
        cell.post = post
        // Debug
        // print(post.key! as String)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postFromCamera" {
            let controller = segue.destination as! ComposeViewController
            controller.key = self.key
        }
    }
    
    // Swipe to the left to delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            //print(self.posts[indexPath.row].key!)
            let ref = self.posts[indexPath.row].key!
            let postIdKey: String = self.posts[indexPath.row].name
            self.posts.remove(at: indexPath.row)
            Database.database().reference().child("addFav").child(self.key).child("photos").child(ref).removeValue()
            Storage.storage().reference().child("images/\(postIdKey)").delete { (error) in
                
                // Keep track of error for debugging
                if let error = error {
                    print(error)
                } else {
                    print("Deleted from storage")
                }
            }
            // Delete that picture from tableview
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
}
