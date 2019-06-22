//
//  Post.swift
//  Sorted
//
//  Created by NgQuocThang on 18/5/19.
//  Copyright © 2019 NgQuocThang. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SwiftyJSON

class Post {
    private var image: UIImage!
    var caption: String!
    var downloadURL: String?
    var key: String!
    var name: String!
    
    init(image: UIImage, caption: String) {
        self.image = image
        self.caption = caption
    }
    
    // Post init to get key value from database, url and key are not shown
    // Code has reference in credit
    init(ref: (key: String, json: JSON)) {
        let json = ref.json
        self.key = ref.key
        self.caption = json["caption"].stringValue
        self.downloadURL = json["url"].string
        self.name = json["name"].string
    }
}
