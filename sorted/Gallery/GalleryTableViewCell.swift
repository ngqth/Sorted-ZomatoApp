//
//  GalleryTableViewCell.swift
//  Sorted
//
//  Created by NgQuocThang on 17/5/19.
//  Copyright © 2019 NgQuocThang. All rights reserved.
//

import UIKit
import FirebaseStorage
import Kingfisher

class GalleryTableViewCell: UITableViewCell {

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postCaption: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // Carry information from Post, start to update UI
    var post: Post! {
        didSet {
            self.updateUI()
        }
    }
    
    func updateUI() {
        self.postCaption.text = post.caption
        self.postCaption.layer.cornerRadius = 10
        self.postImage.image = UIImage(named: "icon")
        self.postImage.layer.cornerRadius = 10
        
        // KingFisher Pod
        // Function:
        // Save images in cache, check if images already in cache to prevent redownload
        // https://github.com/onevcat/Kingfisher
        let url = URL(string: post.downloadURL!)
        self.postImage.kf.setImage(with: url)
    }
}
