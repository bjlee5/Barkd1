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

    @IBOutlet weak var proPic: UIImageView!
    @IBOutlet weak var usernameLabel: UITextView!
    @IBOutlet weak var emailLabel: UITextView!
    @IBOutlet weak var passwordLabel: UITextView!
    @IBOutlet weak var bioLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func backPressed(_ sender: Any) {
    }
    @IBAction func uploadPic(_ sender: Any) {
    }
    @IBAction func updateProfile(_ sender: Any) {
    }

}
