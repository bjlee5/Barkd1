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
    @IBOutlet weak var usernameLabel: UITextView!
    @IBOutlet weak var emailLabel: UITextView!
    @IBOutlet weak var passwordLabel: UITextView!
    @IBOutlet weak var bioLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserInfo()
    }
    
    func loadUserInfo(){
        let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            
            let user = User(snapshot: snapshot)
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
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeedVC")
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func uploadPic(_ sender: Any) {
    }
    @IBAction func updateProfile(_ sender: Any) {
    }
    @IBAction func findFriendsPrs(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersVC")
        self.present(vc, animated: true, completion: nil)
    }

}
