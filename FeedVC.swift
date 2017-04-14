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
import Foundation

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    // TO DO: Try using nil coelessing operator for if let statements concerning current username and e-mail address, profilePic & default picture
    
    
    // Issues with the ProfilePic - only loads properly sometimes, when going back from Profile screen DOES NOT load. When logging in initially, everything DOES load properly.
    
    // Refactor this storage ref using DataService //
    
    var posts = [Post]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var profilePicLoaded = false
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    var following = [String]()
    /// Referencing the Storage DB then, current User
    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userPost: UIImageView!
    @IBOutlet weak var postCaption: UITextField!
    @IBOutlet weak var currentUser: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showCurrentUser()
        followingFriends()
        loadUserInfo()
        fetchPosts()

        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        
        // Dismiss Keyboard //
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
    } // End ViewDidLoad
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showCurrentUser() {
        if FIRAuth.auth()?.currentUser != nil {
            print("BRIAN: There is somebody signed in!!!")
        } else {
            print("Aint nobody signed in!!!")
        }
    }
    
    
    func loadUserInfo(){
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            let imageURL = user.photoURL!
            self.currentUser.text = user.username
            
            /// We are downloading the current user's ImageURL then converting it using "data" to the UIImage which takes a property of data
            self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        if let data = imgData {
                            self.profilePic.image = UIImage(data: data)
                            self.profilePicLoaded = true
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
    
    /// Sort Feed of Posts by Current Date
    func sortDatesFor(this: Post, that: Post) -> Bool {
        return this.currentDate > that.currentDate
    }
    
    // Show Current User Feed //
    
    func followingFriends() {
        
        let ref = FIRDatabase.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let users = snapshot.value as! [String: AnyObject]
            
            for (_, value) in users {
                if let uName = value["username"] as? String {
                    self.userRef.observe(.value, with: { (snapshot) in
                        
                        let myUser = Users(snapshot: snapshot)
                        
                        if uName == myUser.username {
                            if let followingUsers = value["following"] as? [String: String] {
                                for (_, user) in followingUsers {
                                    self.following.append(user)
                                    
                                }
                            }
                            
                            self.following.append((FIRAuth.auth()?.currentUser?.uid)!)
                            print("BRIAN: You are following these users \(self.following)")
                            
                        }
                    })
                }
            }
            
            self.fetchPosts()
        })
    }
    
    func fetchPosts() {
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            self.posts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        print("POST: \(postDict)")
                        if let postUser = postDict["uid"] as? String {
                            if self.following.contains(postUser) {
                                
                            let key = snap.key
                            let post = Post(postKey: key, postData: postDict)
                            self.posts.append(post)
                            
                            
                        }
                    }
                }
            }
            
            self.tableView.reloadData()
            self.posts.sort(by: self.sortDatesFor)
            }
        })
    
    }
    
    // User Feed //
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? PostCell {
            
            if let img = FeedVC.imageCache.object(forKey: post.imageURL as NSString!), let proImg = FeedVC.imageCache.object(forKey: post.profilePicURL as NSString!) {
                cell.configureCell(post: post, img: img, proImg: proImg)
            } else {
                cell.configureCell(post: post)
            }
            return cell
        } else {
            
            return PostCell()
            
        }
    }
    
    
    // Configure Firebase Post //
    
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
        
        guard let proImg = profilePic.image, profilePicLoaded == true else {
            print("BRIAN: The user has no profile pic!")
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
                        
                        if let imgDatar = UIImageJPEGRepresentation(proImg, 0.2) {
                            
                            let imgUidr = NSUUID().uuidString
                            let metadatar = FIRStorageMetadata()
                            metadatar.contentType = "image/jpeg"
                            
                            DataService.ds.REF_PRO_IMAGES.child(imgUidr).put(imgDatar, metadata: metadatar) { (metdata, error) in
                                if error != nil {
                                    print("BRIAN: Unable to upload image to Firebase storage")
                                } else {
                                    print("BRIAN: Successfully printed image to Firebase")
                                    let downloadURL = metdata?.downloadURL()?.absoluteString
                                    if let urlr = downloadURL {
                                        self.postToFirebase(imgUrl: url, imgUrlr: urlr)
                                    }
                                    
                                }
                                
                            }
                        }
                        
                    }
                    
                }
                
            }
            
        }
    }
    
    func imagesForPost(imgUrl: String) -> String {
        let mainImg = imgUrl
        return mainImg
    }
    
    // Retrieve the Current Date //
    
    let realDate = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
    
    // Posting to Firebase //
    
    func postToFirebase(imgUrl: String, imgUrlr: String) {
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        let post: Dictionary<String, Any> = [
            "caption": postCaption.text!,
            "imageURL": imgUrl,
            "likes": 0,
            "postUser": currentUser.text!,
            "profilePicURL": imgUrlr,
            "currentDate": realDate,
            "uid": uid!
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
