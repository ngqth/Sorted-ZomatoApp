//
//  ComposeViewController.swift
//  Sorted
//
//  Created by NgQuocThang on 17/5/19.
//  Copyright © 2019 NgQuocThang. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase

class ComposeViewController: UIViewController {

    @IBOutlet weak var postPic: UIImageView!
    @IBOutlet weak var postCaption: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var captionTextView: UITextView!
    
    var takenImage: UIImage!
    var imagePicker: UIImagePickerController!
    var didShowCamera = false
    var destination = "detail"
    var textViewPlaceholderText = "Write something..."
    var url : String = ""
    var key: String = ""
    var caption: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI setup
        postButton.layer.cornerRadius = 25
        captionTextView.textColor = UIColor.gray
    }
    
    // Camera function
    // Follow class tutorial
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !didShowCamera {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                imagePicker.cameraCaptureMode = .photo
            } else {
                imagePicker.sourceType = .photoLibrary
            }
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // Post will automatically add date-time if no caption is provided
    @IBAction func postTap(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM yyyy"
        let temp1: String = formatter.string(from: NSDate() as Date) + " at "
        formatter.dateFormat = "HH:mm:ss"
        let temp2: String = formatter.string(from: NSDate() as Date)
        let date = temp1 + temp2
        print(date)
        if captionTextView.text == textViewPlaceholderText {
            let caption = "Photo's taken on the " + date
            captionTextView.text = caption
            self.caption = caption
        } else {
            let caption = captionTextView.text
            captionTextView.text = caption
            self.caption = caption!
        }
        
        // Add photo to cloud storage, with reference as name for deletting purpose
        let ref = Database.database().reference()
        let refFavs = ref.child("addFav")
        let refFav = refFavs.child(self.key)
        let refPhotos = refFav.child("photos")
        let postId = refPhotos.childByAutoId()
        let postIdKey: String = postId.key!
        
        // Upload quality is 30% of original picture (source is from camera, not from library)
        // Sufficient quality when view in GalleryView
        let imageData = self.takenImage.jpegData(compressionQuality:0.3)
        let storage = Storage.storage().reference().child("images/\(postIdKey)")
        let metadata = StorageMetadata()
        let uploadTask = storage.putData(imageData!, metadata: metadata)
        
        // After done uploading, will print message and start to update to firebase
        // https://stackoverflow.com/questions/54065547/firestore-storage-upload-task-observer-not-executing-while-app-is-in-background
        uploadTask.observe(.success) { snapshot in
            snapshot.reference.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    if let error = error {
                        print("Error with uploading: \(error.localizedDescription)")
                    }
                    return
                }
                print("Image upload success.")
                self.url = downloadURL.absoluteString
                // Pass to database
                let newPost: [String:Any] = ["url":self.url, "caption":self.caption, "name":postIdKey]
                postId.setValue(newPost)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // Need to investigate issue when add picture, tap cancel not dismiss view
    // Only can dismiss after choosing picture
    @IBAction func dismissTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// ImagePicker view
// Code has reference in credit
extension ComposeViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        print(selectedImage)
        self.postPic.image = selectedImage
        self.takenImage = selectedImage
        didShowCamera = true
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
    
