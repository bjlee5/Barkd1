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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Crash when trying to add profile pic's to the feed ...
    
    // BRIAN: Successfully printed image to Firebase
    // 2017-03-22 18:08:23.380 Barkd1[44447:1778331] *** Terminating app due to uncaught exception 'InvalidFirebaseData', reason: '(setValue:) Cannot store object of type UIImage at profilePicURL. Can only store objects of type NSNumber, NSString, NSDictionary, and NSArray.'
    // *** First throw call stack:

    
    // Refactor this storage ref using DataService // 
    
    var posts = [Post]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userPost: UIImageView!
    @IBOutlet weak var postCaption: UITextField!
    @IBOutlet weak var currentUser: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showCurrentUser()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            self.posts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            
            self.tableView.reloadData()
            
        })
        
        // Dismiss Keyboard //
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showCurrentUser() {
        if FIRAuth.auth()?.currentUser != nil {
            print("BRIAN: There is somebody signed in!!!")
            loadUserInfo()
        } else {
            print("Aint nobody signed in!!!")
        }
    }
    
    // This is the same function (basically) as appears in ProfileVC, look for a way to refactor this code somehow... //
    
    /*
    
    let ref = FIRStorage.storage().reference(forURL: post.imageURL)
    ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
    if error != nil {
    print("BRIAN: Unable to download image from Firebase")
    } else {
    print("Image downloaded successfully")
    if let imgData = data {
    if let img = UIImage(data: imgData) {
    self.postPic.image = img
    FeedVC.imageCache.setObject(img, forKey: post.imageURL as NSString!)
    }
    }
    
    
    }
    })
 */
 
    

    func loadUserInfo(){
        userRef.observe(.value, with: { (snapshot) in
            
            let user = User(snapshot: snapshot)
            let imageURL = user.photoURL!
            self.currentUser.text = user.username
            
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
 
    
    // User Feed //
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? PostCell {
            
            if let img = FeedVC.imageCache.object(forKey: post.imageURL as NSString!) {
                cell.configureCell(post: post, img: img)
            } else {
                cell.configureCell(post: post)
            }
            return cell
        } else {
            
            return PostCell()
            
        }
    }


    // Posting to Firebase //
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            userPost.image = image
            imageSelected = true
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func imagePressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postSubmit(_ sender: Any) {
        guard let caption = postCaption.text, caption != "" else {
            print("BRIAN: Caption must be entered")
            return
        }
        guard let img = userPost.image, imageSelected == true else {
            print("BRIAN: An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metdata, error) in
                if error != nil {
                    print("BRIAN: Unable to upload image to Firebase storage")
                } else {
                    print("BRIAN: Successfully printed image to Firebase")
                    let downloadURL = metdata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                    }
                    
                }
                
            }
        }
        
    }
    
                /* self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imageData, error) in
                    if error == nil {
                        DispatchQueue.main.async {
                            if let data = imageData {
                                self.profilePic.image = UIImage(data: data)
                            }
                        }
                    } else {
                        print(error!.localizedDescription)
                    }
                }) */

    
    func postToFirebase(imgUrl: String) {
        let post: Dictionary<String, Any> = [
            "caption": postCaption.text!,
            "imageURL": imgUrl,
            "likes": 0,
            "postUser": currentUser.text!,
            "profilePicURL": profilePic.image!
        ]
        
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        postCaption.text = ""
        imageSelected = false
        userPost.image = UIImage(named: "add-image")
        
        self.tableView.reloadData()

    }


    // Logging Out //

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
