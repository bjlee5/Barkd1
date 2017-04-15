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
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!

    
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
    
    @IBAction func deleteAccount(_ sender: Any) {
        let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            
            
            FIRAuth.auth()?.currentUser?.delete(completion: { (error) in

                if error == nil {
                            
                            print("BRIAN: Account successfully deleted!")
                            DispatchQueue.main.async {
            
                            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInVC")
                            self.present(vc, animated: true, completion: nil)
                            
                            }
                            
                        } else {
                                
                        print(error?.localizedDescription)
                    }
                })
        })
            
    }
        
    
    
    @IBAction func findFriends(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FriendsVC")
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func editProfile(_ sender: Any) {
        performSegue(withIdentifier: "EditProfileVC", sender: self)
    }

}
