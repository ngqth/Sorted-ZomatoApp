//
//  FavouriteTableViewCell.swift
//  Sorted
//
//  Created by NgQuocThang on 29/4/19.
//  Copyright © 2019 NgQuocThang. All rights reserved.
//

import UIKit

class FavouriteTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLableFavourite: UILabel!
    @IBOutlet weak var cuisineLableFavourite: UILabel!
    @IBOutlet weak var ratingLabelFavourite: UILabel!
    @IBOutlet weak var addLabelFavourite: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
