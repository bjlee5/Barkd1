//
//  FeedVC.swift
//  Barkd1
//
//  Created by MacBook Air on 3/17/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController {
    
    // Refactor this storage ref using DataService // 
    
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    
    @IBOutlet weak var feedLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showCurrentUser()
        loadUserInfo()
    }
    
    func showCurrentUser() {
        if FIRAuth.auth()?.currentUser != nil {
            print("BRIAN: There is somebody signed in!!!")
        } else {
            print("Aint nobody signed in!!!")
        }
    }
    
    // This is the same function (basically) as appears in ProfileVC, look for a way to refactor this code somehow... //
    
    func loadUserInfo(){
        let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            
            let user = User(snapshot: snapshot)
            let imageURL = user.photoURL!
            
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

    
    @IBAction func logOutPress(_ sender: Any) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            KeychainWrapper.standard.removeObject(forKey: KEY_UID)
            
            // This code causes view stacking (potentially memory leaks), but cannot figure out a better way to get to LogInVC and clear the log in text //
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInVC")
            self.present(vc, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    @IBAction func profilePressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileVC")
        self.present(vc, animated: true, completion: nil)
    }
}


