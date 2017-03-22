//
//  NewUserVC.swift
//  Barkd1
//
//  Created by MacBook Air on 3/17/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class NewUserVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var bioField: UITextView!
    @IBOutlet weak var selectImgBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
     
        // Dismiss Keyboard //
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // ImagePicker //
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            profilePic.image = image
            selectImgBtn.isHidden = true
            imageSelected = true
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectImgPress(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Creating a New User //
    
    @IBAction func createUserPress(_ sender: Any) {
        let username = usernameField.text
        let password = passwordField.text
        let email = emailField.text
        let bio = bioField.text
        let pictureData = UIImageJPEGRepresentation(self.profilePic.image!, 0.70)
        
        FIRAuth.auth()?.createUser(withEmail: email!, password: password!, completion: { (user, error) in
            if error != nil {
                
                print("BRIAN: Could not create user")
                
            } else {
                
                print("BRIAN: The user has been created.")
                self.setUserInfo(user: user, email: email!, password: password!, username: username!, bio: bio!, proPic: pictureData as NSData!)
                
            }
        })
    }
    
    func setUserInfo(user: FIRUser!, email: String, password: String, username: String, bio: String, proPic: NSData!) {
        
        let imagePath = "profileImage\(user.uid)/.userPic.jpeg"
        
        let imageRef = STORAGE_REF.child(imagePath)
        
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        
        imageRef.put(proPic as Data, metadata: metaData) { (newMetaData, error) in
            
            if error != nil {
                
                print("BRIAN: Error in setting the user info")
                
            } else {
                
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = username
                
                if let photoURL = newMetaData!.downloadURL() {
                    changeRequest.photoURL = photoURL
                }
                
                changeRequest.commitChanges(completion: { (error) in
                    if error != nil {
                        
                        print("BRIAN: Cannot complete change request!")
                        
                    } else {
                        
                        self.saveUserInfo(user: user, username: username, password: password, bio: bio)
                        
                    }
                })
                
            }
        }
    }
    
    // This is func completeSignInID.createFIRDBuser from SocialApp1. Instead of only providing "provider": user.providerID - there is additional information provided - for the username, profile pic, etc. We need to provide a place for this information to be input. //
    
    private func saveUserInfo(user: FIRUser!, username: String, password: String, bio: String) {
        
        let userInfo = ["email": user.email!, "username": username , "uid": user.uid , "photoURL": String(describing: user.photoURL!), "bio": bio, "provider": user.providerID]
        
        self.completeSignIn(id: user.uid, userData: userInfo)
        print("BRIAN: User info has been saved to the database")
        
        
    }
    
    
    
    @IBAction func backPress(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInVC")
        self.present(vc, animated: true, completion: nil)
    }
    
    // Duplicative function - can I refactor this to DataService?
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("BRIAN: Segway completed \(keychainResult)")
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeedVC")
        self.present(vc, animated: true, completion: nil)
    }
    
}

