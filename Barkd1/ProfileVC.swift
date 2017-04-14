//
//  ProfileVC.swift
//  Barkd1
//
//  Created by MacBook Air on 3/17/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ProfileVC: UIViewController {
    
    // Refactor storage reference // 
    
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }

    @IBOutlet weak var proPic: UIImageView!
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var bioLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserInfo()
    }
    
    func loadUserInfo(){
        let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            self.usernameLabel.text = user.username
            self.bioLabel.text = user.bio
            self.emailLabel.text = user.email
            let imageURL = user.photoURL!
            
        // Clean up profilePic is storage - model after the post-pic, which is creating a folder in storage. This is too messy right now.
            
            self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                
                if error == nil {
                    
                    DispatchQueue.main.async {
                        if let data = imgData {
                            self.proPic.image = UIImage(data: data)
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


    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updatePic(_ sender: Any) {
    }
    
    @IBAction func updateUser(_ sender: Any) {
    }
    
    @IBAction func updateEmail(_ sender: Any) {
        
        if let user = FIRAuth.auth()?.currentUser {
            
            user.updateEmail(emailLabel.text!, completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    let alertView = UIAlertView(title: "Update E-mail", message: "Are you sure you want to change your e-mail?", delegate: self, cancelButtonTitle: "OK")
                    alertView.show()
                }
            
                let changeRequest = user.profileChangeRequest()
                changeRequest.didChangeValue(forKey: "email")
                changeRequest.commitChanges(completion: { (error) in
                    print("BRIAN: Your change request has been committed")
                    if error == nil {
                        
                        let userRef = DataService.ds.REF_USERS.child(user.uid)
                        
                        userRef.updateChildValues(["email": user.email!]) { (error, ref) in
                            
                            if error == nil {
                                print("BRIAN: Your e-mail changes have been updated")
                                
                            }
                            
                        }
                        
                    } else {
                        print(error?.localizedDescription)
                    }
                    
                })
            
                
            })
        }
    }
    
    @IBAction func updatePW(_ sender: Any) {
        
//        if let user = FIRAuth.auth()?.currentUser {
//            
//            user.updatePassword(passwordLabel.text!, completion: { (error) in
//                if let error = error {
//                    print(error.localizedDescription)
//                } else {
//                    let alertView = UIAlertView(title: "Update Password", message: "You've sucessfully updated your password!", delegate: self, cancelButtonTitle: "OK")
//                    alertView.show()
//                }
//                
//                let changeRequest = user.profileChangeRequest()
//                changeRequest.didChangeValue(forKey: "password")
//                changeRequest.commitChanges(completion: { (error) in
//                    print("BRIAN: Your change request has been committed")
//                    if error == nil {
//                        
//                        let userRef = DataService.ds.REF_USERS.child(user.uid)
//                        
//                        userRef.updateChildValues(["password": user.password]) { (error, ref) in
//                            
//                            if error == nil {
//                                print("BRIAN: Your e-mail changes have been updated")
//                                
//                            }
//                            
//                        }
//                        
//                    } else {
//                        print(error?.localizedDescription)
//                    }
//                    
//                })
//                
//                
//            })
//        }
        
    }
    
    @IBAction func updateBio(_ sender: Any) {
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        if let user = FIRAuth.auth()?.currentUser {
            user.delete(completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    let alertView = UIAlertView(title: "Delete User", message: "Are you sure you want to delete user?", delegate: self, cancelButtonTitle: "OK")
                    alertView.show()
                }
                
                
            })
        }
        
    }
    
    @IBAction func findFriends(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FriendsVC")
        self.present(vc, animated: true, completion: nil)
    }

}
