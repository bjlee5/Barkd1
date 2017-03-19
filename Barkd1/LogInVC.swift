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
    
/* let userData = ["provider": user.providerID]
 self.completeSignIn(id: user.uid, userData: userData)*/
    
    // This is not signing the user in properly. Stops an e-mail that hasn't been authenticated but will not sign in a current user // 
 
    @IBAction func loginPress(_ sender: Any) {
        guard loginField.text != "", passwordField.text != "" else { return }
        FIRAuth.auth()?.signIn(withEmail: loginField.text!, password: passwordField.text!, completion: { (user, error) in
            if let error = error {
                print("BRIAN: Password and E-mail address do not match our records!")
                
                let alertController = UIAlertController(title: "Oops!", message: "Your e-mail and/or password do not match our records!", preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
                let OKAction = UIAlertAction(title: "Try Again", style: .default) { (action:UIAlertAction) in
                    print("You've pressed OK button");
                    
                }
                
                alertController.addAction(OKAction)
            }
            if let user = user {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeedVC")
                self.present(vc, animated: true, completion: nil)
            }
        })
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
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeedVC")
        self.present(vc, animated: true, completion: nil)
    }
    
}



