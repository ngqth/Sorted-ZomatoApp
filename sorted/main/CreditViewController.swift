//
//  CreditViewController.swift
//  Sorted
//
//  Created by NgQuocThang on 18/5/19.
//  Copyright © 2019 NgQuocThang. All rights reserved.
//

import UIKit

class CreditViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImage.init(named: "aqua")
        let backgroundImageView = UIImageView.init(frame: self.view.frame)
        
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 0.7
        
        self.view.insertSubview(backgroundImageView, at: 0)
        // Do any additional setup after loading the view.
    }
    @IBAction func doneTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
