//
//  EditProfileVC.swift
//  Barkd1
//
//  Created by MacBook Air on 4/14/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase

class EditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }


    @IBOutlet weak var profilePic: CircleView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var bioField: UITextField!
    @IBOutlet weak var changeProBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCurrentUser()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
    }

    
    func fetchCurrentUser() {
        let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            self.usernameField.text = user.username
            self.bioField.text = user.bio
            self.emailField.text = user.email
            let imageURL = user.photoURL!
            
            // Clean up profilePic is storage - model after the post-pic, which is creating a folder in storage. This is too messy right now.
            
            self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                
                if error == nil {
                    
                    DispatchQueue.main.async {
                        if let data = imgData {
                            self.profilePic.image = UIImage(data: data)
                        }
                    }
                    
                    
                } else {
                    print(error!.localizedDescription)
                    
                }
                
            })
            
            
        }) { (error) in
            print(error.localizedDescription)
        }

    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            profilePic.image = image
            imageSelected = true
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }


    @IBAction func changePic(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func updateProfile(_ sender: Any) {
        
        // TODO: THERE IS NO ERROR HANDLING HERE
        let user = FIRAuth.auth()?.currentUser
        
        let username = usernameField.text
        let password = passwordField.text
        let email = emailField.text
        let bio = bioField.text
        let pictureData = UIImageJPEGRepresentation(self.profilePic.image!, 0.70)
        
        let imgUid = NSUUID().uuidString
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        
        DataService.ds.REF_PRO_IMAGES.child(imgUid).put(pictureData! as Data, metadata: metadata) { (newMetaData, error) in
            
            if error != nil {
                
                print("BRIAN: Error uploading profile Pic to Firebase")
                
            } else {
                print("BRIAN: New metadata stuff's workin.")
                
                let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                changeRequest?.didChangeValue(forKey: "email")
                changeRequest?.didChangeValue(forKey: "password")
                changeRequest?.displayName = username
                
                user?.updateEmail(email!, completion: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                })
                
                user?.updatePassword(password!, completion: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                })
                
                let photoString = newMetaData!.downloadURL()?.absoluteString
                let photoURL = newMetaData!.downloadURL()
                changeRequest?.photoURL = photoURL
                
                changeRequest?.commitChanges(completion: { (error) in
                    
                    if error == nil {
                    
                    let user = FIRAuth.auth()?.currentUser
                    let userInfo = ["email": user!.email!, "username": username as Any , "uid": user!.uid, "photoURL": photoString!, "bio": bio!] as [String : Any]
                    
                    let userRef = DataService.ds.REF_USERS.child((user?.uid)!)
                    userRef.setValue(userInfo)
                    print("BRIAN: New values saved properly!")
                      
                        }
                    })
                    
                }
            }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeedVC")
        self.present(vc, animated: true, completion: nil)

        
        }
    
    
    @IBAction func backPress(_ sender: Any) {
    }

    }

