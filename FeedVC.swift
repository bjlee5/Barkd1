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
    
    @IBOutlet weak var feedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showCurrentUser()
    }
    
    // Attempting to get the username to display on the feed... So far this is only working for items that are mebmers of FIRAUTH.currentUser i.e. email, providerID, etc. //
    
    func showCurrentUser() {
        if FIRAuth.auth()?.currentUser != nil {
            print("BRIAN: There is somebody signed in!!!")
        } else {
            print("Aint nobody signed in!!!")
        }
    }
    
    /*
     func displayCurrentUser() {
     let user = FIRAuth.auth()?.currentUser
     let username = user?.providerID
     feedLabel.text = username
     }
     */
    
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
}


