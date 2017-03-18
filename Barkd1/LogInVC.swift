//
//  ViewController.swift
//  Barkd1
//
//  Created by MacBook Air on 3/17/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import SwiftKeychainWrapper

class LogInVC: UIViewController {
    
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showCurrentUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID){
            print("BRIAN: ID found in keychain")
            performSegue(withIdentifier: "FeedVC", sender: nil)
        }
        
    }
    
    func showCurrentUser() {
        if FIRAuth.auth()?.currentUser != nil {
            print("BRIAN: There is somebody signed in!!!")
        } else {
            print("BRIAN: Aint nobody signed in!!!")
        }
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("BRIAN: Unable to authenticate with Firebase")
                print("BRIAN: \(error?.localizedDescription)")
            } else {
                print("BRIAN: Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
        
    }
    
    // Facebook login is not working. User cannot authenticate w/ Firebase? //
    
    @IBAction func loginPress(_ sender: Any) {
        if let email = loginField.text, let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("BRIAN: Email user authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("BRIAN: Unable to authenticate with Firebase using email")
                        } else {
                            print("BRIAN: Successfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                                
                            }
                        }
                    })
                }
 
            })
            
        }
        
    }
    
    
    @IBAction func fbLoginPress(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("BRIAN: Unable to Authenticate")
            } else if result?.isCancelled == true {
                print("BRIAN: User canceled Facebook authentication")
            } else {
                print("BRIAN: Succesfully autheticated with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
            
        }
    }
    
    @IBAction func createPress(_ sender: Any) {
        performSegue(withIdentifier: "NewUserVC", sender: self)
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("BRIAN: Segway completed \(keychainResult)")
        performSegue(withIdentifier: "FeedVC", sender: nil)
    }
    
}



