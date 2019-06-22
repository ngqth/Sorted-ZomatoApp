//
//  ViewController.swift
//  Sorted
//
//  Created by NgQuocThang on 27/4/19.
//  Copyright © 2019 NgQuocThang. All rights reserved.
//

import UIKit
import FirebaseAuth
import Material

class ViewController: UIViewController {

    @IBOutlet var emailTextView: TextField!
    @IBOutlet var passTextView: TextField!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var creditButton: UIButton!
    
    var signUpMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change custom background
        // https://stackoverflow.com/questions/18720156/adding-background-image-into-view-controller
        let backgroundImage = UIImage.init(named: "aqua")
        let backgroundImageView = UIImageView.init(frame: self.view.frame)
        
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 1
        
        self.view.insertSubview(backgroundImageView, at: 0)
        
        // UI customisation
        // Use Mateiral pod
        // https://cocoapods.org/pods/Material
        topButton.layer.cornerRadius = 0
        topButton.layer.masksToBounds = true
        topButton.layer.cornerRadius = 25
        
        bottomButton.layer.cornerRadius = 0
        bottomButton.layer.masksToBounds = true
        
        creditButton.layer.cornerRadius = 0
        creditButton.layer.masksToBounds = true
        
        emailTextView.placeholderNormalColor = Color.white
        emailTextView.placeholderActiveColor = Color.white
        emailTextView.textColor = Color.white
        emailTextView.dividerActiveColor = Color.white
        
        passTextView.placeholderNormalColor = Color.white
        passTextView.placeholderActiveColor = Color.white
        passTextView.textColor = Color.white
        passTextView.dividerActiveColor = Color.white
    }
    
    @IBAction func topTap(_ sender: Any) {
        
        // Check if email or pass is null.
        if emailTextView.text == "" || passTextView.text == "" {
            displayAlert(title: "Missing Info", message: "You must provide Email and Password")
        } else {
            if let email = emailTextView.text {
                if let pass = passTextView.text {
                    // SIGN UP
                    if signUpMode {
                        Auth.auth().createUser(withEmail: email, password: pass, completion: {(user, error) in
                            if error != nil {
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                                print("Sign Up Success")
                                self.performSegue(withIdentifier: "searchSegue", sender: nil)
                            }
                        })
                    // SIGN IN
                    } else {
                        Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
                            if error != nil {
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                                print("Log In Success")
                                self.performSegue(withIdentifier: "searchSegue", sender: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Switch mode
    @IBAction func bottomTap(_ sender: Any) {
        if signUpMode {
            topButton.setTitle("Log In", for: .normal)
            bottomButton.setTitle("Sign Up", for: .normal)
            signUpMode = false
        } else {
            topButton.setTitle("Sign Up", for: .normal)
            bottomButton.setTitle("Log In", for: .normal)
            signUpMode = true
        }
    }
    
    @IBAction func creditTap(_ sender: Any) {
        self.performSegue(withIdentifier: "showCredit", sender: nil)
    }
}
