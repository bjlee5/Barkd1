
//
//  PostCellTableViewCell.swift
//  Barkd1
//
//  Created by MacBook Air on 3/18/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import Foundation 

class PostCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var likesImage: UIImageView!
    @IBOutlet weak var postPic: UIImageView!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var likesNumber: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
  
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likesTapped))
        tap.numberOfTapsRequired = 1
        likesImage.addGestureRecognizer(tap)
        likesImage.isUserInteractionEnabled = true
        
        let currentDate = NSDate()
        dateLabel.text = "\(currentDate)"
        
    }
    
    // Load Current User //
    
    func loadUserInfo(){
        let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            self.username.text = user.username
            })
        { (error) in
            print(error.localizedDescription)
        }
    }
//
    
    func configureCell(post: Post, img: UIImage? = nil, proImg: UIImage? = nil) {
        
        self.post = post
        self.likesRef = DataService.ds.REF_CURRENT_USERS.child("likes").child(post.postKey)
        self.postText.text = post.caption
        self.likesNumber.text = "\(post.likes)"
        self.dateLabel.text = post.currentDate
        
        let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            self.username.text = "\(post.postUser)"
        })
        
        if img != nil {
            self.postPic.image = img
        } else {
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
            
       if proImg != nil {
                    self.profilePic.image = proImg
                } else {
                    let ref = FIRStorage.storage().reference(forURL: post.profilePicURL)
                    ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (proData, error) in
                        if error != nil {
                            print("BRIAN: Unable to download image from Firebase")
                        } else {
                            print("Image downloaded successfully")
                            if let proimgData = proData {
                                if let proImg = UIImage(data: proimgData) {
                                    self.profilePic.image = proImg
                                    FeedVC.imageCache.setObject(proImg, forKey: post.profilePicURL as NSString!)
                                }
                            }
                            
                            
                        }
                    })
                    
                }
            
        }
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImage.image = UIImage(named: "empty-heart")
            } else {
                self.likesImage.image = UIImage(named: "filled-heart")
            }
        })
    }
    
    func likesTapped(sender: UIGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImage.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likesImage.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
}
